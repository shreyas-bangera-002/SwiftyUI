//
//  Protocols.swift
//  Plowz
//
//  Created by Shreyas Bangera on 07/11/2019.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

public protocol Initializable {}

public extension Initializable where Self: UIView {
    @discardableResult
    init(_ closure: (Self) -> Void) {
        self.init(frame: .zero)
        closure(self)
    }
}

extension UIView: Initializable {}

private class Actor<T> {
    @objc func act(sender: AnyObject) { closure(sender as! T) }
    fileprivate let closure: (T) -> Void
    init(acts closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}

private class GreenRoom {
    fileprivate var actors: [Any] = []
}

private var GreenRoomKey: UInt32 = 893

private func register<T>(_ actor: Actor<T>, to object: AnyObject) {
    let room = objc_getAssociatedObject(object, &GreenRoomKey) as? GreenRoom ?? {
        let room = GreenRoom()
        objc_setAssociatedObject(object, &GreenRoomKey, room, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return room
        }()
    room.actors.append(actor)
}

public protocol ActionClosurable {}
public extension ActionClosurable where Self: AnyObject {
    func convert(closure: @escaping (Self) -> Void, toConfiguration configure: (AnyObject, Selector) -> Void) {
        let actor = Actor(acts: closure)
        configure(actor, #selector(Actor<AnyObject>.act(sender:)))
        register(actor, to: self)
    }
    static func convert(closure: @escaping (Self) -> Void, toConfiguration configure: (AnyObject, Selector) -> Self) -> Self {
        let actor = Actor(acts: closure)
        let instance = configure(actor, #selector(Actor<AnyObject>.act(sender:)))
        register(actor, to: instance)
        return instance
    }
}

extension NSObject: ActionClosurable {}

extension ActionClosurable where Self: UIControl {
    @discardableResult
    public func on(_ controlEvents: UIControl.Event, closure: @escaping (Self) -> Void) -> Self {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1, for: controlEvents)
        })
        return self
    }
}

extension ActionClosurable where Self: UIButton {
    public func onTap(_ closure: @escaping (Self) -> Void) {
        on(.touchUpInside, closure: closure)
    }
}

extension ActionClosurable where Self: UIGestureRecognizer {
    public func onGesture(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1)
        })
    }
    public init(closure: @escaping (Self) -> Void) {
        self.init()
        onGesture(closure)
    }
}

extension ActionClosurable where Self: UIBarButtonItem {
    public init(title: String, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        self.title = title
        self.style = style
        self.onTap(closure)
    }
    public init(image: ImageNameable?, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        if let image = image {
            self.image = UIImage(image)
        }
        self.style = style
        self.onTap(closure)
    }
    public init(barButtonSystemItem: UIBarButtonItem.SystemItem, closure: @escaping (Self) -> Void) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
        self.onTap(closure)
    }
    public func onTap(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.target = $0
            self.action = $1
        })
    }
}

public protocol Then {}

public extension Then where Self: AnyObject {
    @discardableResult
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}

extension NSObject: Then {}
extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}
extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}

protocol Reusable: class {}

extension Reusable {
    static var reuseId: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionReusableView: Reusable {}

public protocol Configurable where Self: UIView {
    associatedtype T
    func configure(_ item: T)
}

struct ConfigurableAssociatedKeys {
    static var ItemKey = "ItemKey"
}

extension Configurable {
    public var item: T? {
        get {
            return objc_getAssociatedObject(self, &ConfigurableAssociatedKeys.ItemKey) as? T
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &ConfigurableAssociatedKeys.ItemKey,
                    newValue as T?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    func configureView(_ item: T) {
        self.item = item
        configure(item)
    }
}

public protocol EndpointType {
    var value: String { get }
    var mockJSON: String { get }
}

public protocol ImageNameable {
    var value: String { get }
}

public extension ImageNameable where Self: RawRepresentable, RawValue == String {
    var value: String { rawValue }
}

public protocol Identifiable {
    var id: String { get }
}

public protocol Valuable {
    var value: String { get }
}
