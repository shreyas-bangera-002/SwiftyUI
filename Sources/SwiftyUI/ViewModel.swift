//
//  ViewModel.swift
//  
//
//  Created by SpringRole on 10/04/2020.
//

import Foundation

open class ViewModel {
    public var startActivity: FinallyBlock = nil
    public var stopActivity: FinallyBlock = nil
    public var onError: ErrorBlock = nil
    private var requests = [String: Requester]()
    private var token: NSObjectProtocol?
    
    public init() {
        token = NotificationCenter.observe(.networkChanged) { [weak self] in
            guard ($0?[.isReachable]).boolValue else { return }
            self?.requests.values.forEach { $0.start() }
        }
    }
    
    open func fetch() {}
    open func refresh() {}
    
    public func request<T: Decodable>(_ request: Request<T>, shouldRetry: Bool = false, onSuccess: SuccessBlock<T> = nil, errorBlock: ErrorBlock = nil) {
        let req = request.method.value + "_" + request.endpoint.value
        if requests[req].isNil {
            requests[req] = .init { [weak self] in
                if request.requestType == .blocking {
                    self?.startActivity?()
                }
                T.request(
                    methodType: request.method,
                    endpoint: request.endpoint,
                    headers: request.headers,
                    params: request.params,
                    mock: request.mock,
                    onSuccess: {
                        request.data?.value = $0
                        onSuccess?($0)
                        self?.requests.removeValue(forKey: req)
                    },
                    onError: { errorBlock?($0) ?? self?.onError?($0) },
                    whenUnauthorized: { [weak self] in
                        (self as? SessionTokenProtocol)?.fetchSessionToken {
                            self?.requests[req]?.start()
                        }
                    },
                    finally: {
                        self?.stopActivity?()
                        self?.requests[req]?.stop()
                        if !shouldRetry {
                            self?.requests.removeValue(forKey: req)
                        }
                    }
                )
            }
        }
        requests[req]?.start()
    }
    
    public func execute(_ sequence: RequestSequence, completion: FinallyBlock) {
        sequence.exec(onError: { [weak self] in self?.onError?($0) }, onSuccess: completion)
    }
    
    public func combine<T: Decodable>(_ requests: [Request<T>], completion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        startActivity?()
        requests.forEach { req in
            group.enter()
            API<T>.request(
                req.endpoint,
                methodType: req.method,
                params: req.params,
                mock: req.mock,
                onSuccess: { req.data?.value = $0 },
                onError: nil,
                //TODO: Handle this
                whenUnauthorized: nil,
                finally: { group.leave() }
            )
        }
        group.notify(queue: .main) { [weak self] in
            self?.stopActivity?()
            completion?()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token!)
        log("\(#function) \(Self.self)")
    }
}
