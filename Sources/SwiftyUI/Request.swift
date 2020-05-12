//
//  Request.swift
//  
//
//  Created by SpringRole on 10/04/2020.
//

import Foundation

public enum RequestType { case blocking, nonblocking }

public struct Request<T: Decodable> {
    let type: T.Type
    let method: MethodType
    var requestType: RequestType = .blocking
    var headers: Headers?
    var params: Params?
    let endpoint: EndpointType
    var data: Dynamic<T>?
    var mock: Bool
    
    public init(type: T.Type,
                method: MethodType,
                requestType: RequestType = .blocking,
                headers: Headers? = nil,
                params: Params? = nil,
                endpoint: EndpointType,
                data: Dynamic<T>? = nil,
                mock: Bool = false) {
        self.type = type
        self.method = method
        self.requestType = requestType
        self.headers = headers
        self.params = params
        self.endpoint = endpoint
        self.data = data
        self.mock = mock
    }
}

public class RequestSequence: Then {
    private var queue = [(ErrorBlock, FinallyBlock) -> Void]()
    
    public func add<T: Decodable>(_ request: Request<T>) {
        self.queue.append({ onError, onSuccess in
            request.type.request(
                methodType: request.method,
                endpoint: request.endpoint,
                headers: request.headers,
                params: request.params,
                mock: request.mock,
                onSuccess: { request.data?.value = $0; onSuccess?() },
                onError: onError,
                //TODO: handle this
                whenUnauthorized: nil,
                finally: nil
            )
        })
    }
    
    public func exec(onError: ErrorBlock, onSuccess: FinallyBlock) {
        if let request = queue.first {
            request({ onError?($0) }, { self.removeFirst(); self.exec(onError: onError, onSuccess: onSuccess) })
        } else {
            onSuccess?()
        }
    }
    
    private func removeFirst() {
        _ = queue.removeFirst()
    }
}

public enum RequestStatus { case active, inactive }

public class Requester {
    let exec: () -> Void
    private(set) var status: RequestStatus = .inactive
    
    public init(_ exec: @escaping () -> Void) {
        self.exec = exec
    }
    
    public func start() {
        guard status == .inactive else { return }
        status = .active
        exec()
    }
    
    public func stop() {
        status = .inactive
    }
}
