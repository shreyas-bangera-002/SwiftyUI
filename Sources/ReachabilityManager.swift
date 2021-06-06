//
//  ReachabilityManager.swift
//  Plowz
//
//  Created by Shreyas Bangera on 14/11/2019.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import Foundation

public class ReachabilityManager {
    private init() {}
    public static let shared = ReachabilityManager()
    private let reachability = try! Reachability()
    
    public var isReachable: Bool { reachability.connection != .unavailable }
    
    public func configure() {
        reachability.whenReachable = {_ in
            NotificationCenter.post(.networkChanged, info: [.isReachable: true])
        }
        reachability.whenUnreachable = {_ in
            NotificationCenter.post(.networkChanged, info: [.isReachable: false])
        }
        do {
            try reachability.startNotifier()
        } catch {
            log("Couldn't start reachability notifier")
        }
    }
}

public extension NotificationCenter {
    
    static func post(_ name: NSNotification.Name, info: NotificationInfo) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
    }
    
    static func observe(_ name: NSNotification.Name, closure: @escaping (NotificationInfo) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: {
            closure($0.userInfo?.info)
        })
    }
}

public extension NSNotification.Name {
    static let networkChanged = NSNotification.Name("networkChanged")
    static let dismissRetry = NSNotification.Name("dismissRetry")
}

public typealias NotificationInfo = [NotificationInfoType: Any]?

public enum NotificationInfoType { case isReachable }

fileprivate extension Dictionary where Key == AnyHashable, Value == Any {
    var info: [NotificationInfoType: Any]? {
        self as? [NotificationInfoType: Any]
    }
}
