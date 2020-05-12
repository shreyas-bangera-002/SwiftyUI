//
//  FoundationExtensions.swift
//  Plowz
//
//  Created by SpringRole on 07/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import Foundation

public extension Array {
    static var empty: [Element] { [Element]() }
    
    func add(_ items: [Element]) -> [Element] {
        var list = self
        list.append(contentsOf: items)
        return list
    }
    
    func last(_ slice: Int) -> [Element] {
        guard slice <= count else { return .empty }
        return Array(self[count-slice..<count])
    }
    
    mutating func add(_ items: [Element], when value: Bool) {
        if value {
            self = add(items)
        }
    }
    
    var json: String {
        let invalidJson = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}

public extension Optional {
    var isNil: Bool { self == nil }
    var boolValue: Bool { (self as? Bool) == true }
}

public extension Optional where Wrapped == String {
    var value: String { self ?? "" }
}

public extension Optional where Wrapped == Bool {
    var value: Bool { self ?? false }
}

public extension Optional where Wrapped == Double {
    var value: Double { self ?? 0 }
}

public extension Int {
    mutating func increment() -> Int {
        self = self + 1
        return self
    }
}

public extension String {
    var isInt: Bool { !Int(self).isNil }
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

public extension Dictionary {
    var json: String {
        let invalidJson = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
}

extension String: Valuable {
    public var value: String { return self }
}

public extension Double {
    var price: String {
        String(format: "$%.2f", self)
    }
    var string: String { self == 0 ? "" : String(self) }
}

public extension Set {
    mutating func toggle(_ item: Element) {
        if contains(item) {
            remove(item)
        } else {
            insert(item)
        }
    }
}

public protocol Injectable {
    func appSetup()
}

public extension Injectable {
    func injectionSetup() {
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"),
            object: nil,
            queue: nil) { _ in
                self.appSetup()
        }
        #endif
    }
}

public extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }
}

public extension Decodable {
    mutating func configure(_ data: Data?) {
        guard let data = data else { return }
        guard let value = try? JSONDecoder().decode(Self.self, from: data) else { return }
        self = value
    }
}

public protocol Diffable {
    func hasDiff(_ value: Self?) -> Bool
}

extension Array: Diffable where Element: Diffable {
    public func hasDiff(_ value: Array?) -> Bool {
        guard value?.count == count else { return true }
        return enumerated().map({ true == $0.1.hasDiff(value?[$0.0]) }).reduce(false, { $0 || $1 })
    }
}
