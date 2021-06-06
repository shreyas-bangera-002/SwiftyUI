//
//  ViewModel.swift
//  
//
//  Created by Shreyas Bangera on 10/04/2020.
//

import Foundation

open class ViewModel {
    public var startActivity: FinallyBlock = nil
    public var stopActivity: FinallyBlock = nil
    public var onError: ErrorBlock = nil
    public var onRetryableError: ((Error, FinallyBlock, FinallyBlock) -> Void)? = nil
    private var requests = [String: Requester]()
    public var tokens = [NSObjectProtocol]()
    
    public init() {
        tokens.append(
            NotificationCenter.observe(.networkChanged) { [weak self] in
                guard ($0?[.isReachable]).boolValue else { return }
                self?.requests.values.forEach { $0.start() }
            }
        )
    }
    
    public func networkUpdate() {
        guard !ReachabilityManager.shared.isReachable else { return }
        onError?(Errors.custom("The Internet connection appears to be offline", nil))
    }
    
    open func fetch() {}
    open func refresh() {}
    
    public func request<T: Decodable>(_ request: Request<T>, shouldRetry: Bool = false, onSuccess: SuccessBlock<T> = nil, errorBlock: ErrorBlock = nil, finally: FinallyBlock = nil) {
        let req = request.method.value + "_" + request.endpoint.value + (request.params.isNil ? "" : request.params!.map { "\($0.0)_\($0.1)"}.joined(separator: ","))
        if requests[req].isNil {
            requests[req] = .init { [weak self] in
                if request.requestType == .blocking, request.autoActivity {
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
                        if request.autoActivity { self?.stopActivity?() }
                        onSuccess?($0)
                        self?.requests.removeValue(forKey: req)
                    },
                    onError: {
                        if request.autoActivity { self?.stopActivity?() }
                        errorBlock?($0) ?? self?.onError?($0)
                    },
                    whenUnauthorized: { [weak self] in
                        (self as? SessionTokenProtocol)?.fetchSessionToken {
                            self?.requests[req]?.restart()
                        }
                    },
                    finally: {
                        self?.requests[req]?.stop()
                        if !shouldRetry {
                            self?.requests.removeValue(forKey: req)
                        }
                        finally?()
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
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        log("\(#function) \(Self.self)")
    }
}
