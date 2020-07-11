//
//  DynamicValue.swift
//  
//
//  Created by Shreyas Bangera on 10/04/2020.
//

import Foundation

public class Dynamic<T> {
    private var index = -1
    private var observers = [Int: SuccessBlock<T>]()
    public var onRemove: ((Int) -> Void)?
    private var canUpdate = true
    
    public var value: T {
        willSet {
            guard canUpdate else { canUpdate.toggle(); return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                log("Observers: \(self.observers.count), value: \(T.Type.self)")
                self.observers.forEach { $1?(newValue) }
            }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func subscribe(_ observer: SuccessBlock<T>, disposeWith disposable: Disposable) {
        index += 1
        observers[index] = observer
        disposable.bag.append({ [weak self] in
            guard let self = self else { return }
            self.observers.removeValue(forKey: self.index)
            log("dispose Observers: \(self.observers.count), value: \(T.Type.self)")
        })
    }
    
    public func updateAndSubscribe(_ observer: SuccessBlock<T>, disposeWith disposable: Disposable) {
        subscribe(observer, disposeWith: disposable)
        observer?(value)
    }
    
    public func remove<E: Identifiable>(_ item: E) {
        guard var value = value as? Array<E> else { return }
        if let index = value.firstIndex(where: { $0.id == item.id }) {
            value.remove(at: index)
            onRemove?(index)
            canUpdate.toggle()
            self.value = value as! T
        }
    }
    
    func remove(at index: Int) {
        guard var value = value as? Array<Any> else { return }
        value.remove(at: index)
        onRemove?(index)
//        canUpdate.toggle()
        self.value = value as! T
    }
    
    deinit {
        observers.removeAll()
        log("\(#function) \(Self.self)")
    }
}

public class Disposable {
    var bag = [FinallyBlock]()
    public init() {}
    public func dispose() {
        bag.forEach { $0?() }
    }
}
