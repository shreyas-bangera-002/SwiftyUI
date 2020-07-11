//
//  API.swift
//  Plowz
//
//  Created by Shreyas Bangera on 07/11/2019.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import AdSupport

public struct Empty: Codable {}
public typealias Params = [String: Any]
public typealias Headers = [String: String]
public typealias ErrorBlock = ((Error) -> Void)?
public typealias FinallyBlock = (() -> Void)?
public typealias SuccessBlock<T> = ((T) -> Void)?

public struct EmptyResponse: Codable {
    init?(json: Any) {
        guard let _ = json as? [AnyHashable: Any] else { return nil }
    }
}

public struct SessionToken: Codable {
    public let id, authToken: String
}

public enum MethodType: String {
    case get, post, put, delete, patch
    var value: String { rawValue.uppercased() }
}

public enum Errors: LocalizedError, Equatable {
    case emptyData, unknownError
    case custom(String?, Int? = nil)
    
    public var errorDescription: String? {
        switch self {
        case .emptyData:
            return "No Content"
        case .unknownError:
            return "Looks like something went wrong, Please try again or contact customer support for help"
        case let .custom(error, _):
            return error ?? Errors.unknownError.errorDescription
        }
    }
    
    public var code: Int? {
        switch self {
        case let .custom(_, code): return code
        default: return nil
        }
    }
}

public struct ImageModel: Identifiable, Codable {
    public let id: String
    public let image: Data
    public let date: Double
    public init(id: String, image: Data, date: Double) {
        self.id = id
        self.image = image
        self.date = date
    }
}

public class API<T: Decodable> {
    private init() {}
    public static func request(_ endpoint: EndpointType,
                        methodType: MethodType,
                        headers: Headers? = nil,
                        params: Params? = nil,
                        mock: Bool = false,
                        onSuccess: ((T) -> Void)? = nil,
                        onError: ErrorBlock = nil,
                        whenUnauthorized: FinallyBlock,
                        finally: FinallyBlock = nil) {
        guard !Constants.shared.isMockingEnabled, !mock else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onSuccess?(Bundle.main.decode(T.self, from: endpoint.mockJSON))
                finally?()
            }
            return
        }
        var urlString = endpoint.value
        var httpBody: Data?
        if let params = params {
            switch methodType {
            case .get, .delete:
                urlString += params.queryParams
            case .post, .put, .patch:
                httpBody = params.serialized
            }
        }
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = methodType.value
        request.httpBody = httpBody
        request.addHeaders(headers)
        if Constants.shared.isCachingEnabled {
            if let data = URLCache.shared.cachedResponse(for: request)?.data,
                let model = try? JSONDecoder().decode(T.self, from: data) {
                onSuccess?(model); finally?()
            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            log("Request: ", request)
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                guard err == nil else {
                    DispatchQueue.main.async { onError?(err!); finally?() }
                    return
                }
                guard let response = response?.httpUrlResponse else {
                    DispatchQueue.main.async { onError?(Errors.emptyData); finally?(); }
                    return
                }
                switch response.statusCode {
                case 401:
                    DispatchQueue.main.async { whenUnauthorized?(); }
                case 300...600:
                    DispatchQueue.main.async {
                        onError?(Errors.custom(data?.serializedMessage, response.statusCode))
                        finally?()
                    }
                case 204:
                    DispatchQueue.main.async { onError?(Errors.emptyData); finally?() }
                default:
                    guard let data = data else {
                        DispatchQueue.main.async { onError?(Errors.emptyData); finally?() }
                        return
                    }
                    do {
                        log("Response: ", data.serialized ?? "empty")
                        let model: T
                        if T.self is Empty.Type {
                            model = Empty() as! T
                        } else {
                            model = try JSONDecoder().decode(T.self, from: data)
                            if Constants.shared.isCachingEnabled {
                                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: request)
                            }
                        }
                        DispatchQueue.main.async { onSuccess?(model); finally?() }
                    } catch let error {
                        DispatchQueue.main.async { onError?(error); finally?() }
                    }
                }
            }.resume()
        }
    }
}

public class Upload: NSObject, URLSessionTaskDelegate {
    private override init() {}
    public static let shared = Upload()
    lazy var session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "uploadImages"), delegate: self, delegateQueue: nil)
    var onSuccess: FinallyBlock = nil
    var onError: ErrorBlock = nil
    var finally: FinallyBlock = nil
    var cleanup: FinallyBlock = nil
    var id = ""
    
    public func execute(_ endpoint: EndpointType,
                        images: [ImageModel],
                        id: String,
                        json: String? = nil,
                        onSuccess: FinallyBlock = nil,
                        onError: ErrorBlock = nil,
                        finally: FinallyBlock = nil,
                        cleanup: FinallyBlock = nil) {
        guard let url = URL(string: endpoint.value) else { return }
        let boundary = String(repeating: "-", count: 20) + UUID().uuidString + "\(Int(Date.timeIntervalSinceReferenceDate))"
        var request = URLRequest(url: url)
        request.httpMethod = MethodType.post.value
        request.addHeaders([
            "id": id,
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ])
        var data = Data()
        if let json = json {
            data.addMultipartField(boundary: boundary, fieldName: "metadata", fieldValue: json)
        }
        images.forEach {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\($0.id).jpeg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: text/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append($0.image)
        }
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        self.id = id
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("images_\(id)")
        try? data.write(to: localURL)
        self.onSuccess = onSuccess
        self.onError = onError
        self.finally = finally
        self.cleanup = cleanup
        session.uploadTask(with: request, fromFile: localURL).resume()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in self?.finally?() }
        guard let statusCode = task.response?.httpUrlResponse?.statusCode else {
            DispatchQueue.main.async { [weak self] in self?.onError?(error ?? Errors.custom("Something went wrong", nil)) }
            return
        }
        if (200..<300).contains(statusCode) {
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("images_\(id)")
            try? FileManager.default.removeItem(at: localURL)
            DispatchQueue.main.async { [weak self] in self?.onSuccess?(); self?.cleanup?() }
        } else {
            DispatchQueue.main.async { [weak self] in self?.onError?(error ?? Errors.custom("Something went wrong", statusCode)); self?.cleanup?() }
        }
    }
}

public extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle")
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            log(error)
            fatalError("Failed to decode \(file) from bundle")
        }
    }
}

public extension Decodable {
    static func request(methodType: MethodType, endpoint: EndpointType, headers: Headers? = nil, params: Params? = nil, mock: Bool = false, onSuccess: @escaping (Self) -> Void, onError: ErrorBlock, whenUnauthorized: FinallyBlock, finally: FinallyBlock) {
        API<Self>.request(endpoint, methodType: methodType, headers: headers, params: params, mock: mock, onSuccess: onSuccess, onError: onError, whenUnauthorized: whenUnauthorized, finally: finally)
    }
}

public extension Dictionary where Key == String, Value: Any {
    var queryParams: String {
        isEmpty ? "" : ("?" + compactMap {
            guard let value = "\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return $0.key + "=" + value
        }.joined(separator: "&"))
    }
}

fileprivate extension Data {
    var serialized: Any? {
        try? JSONSerialization.jsonObject(with: self, options: [])
    }
    
    var serializedMessage: String? {
        (try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any])?["message"] as? String
    }
    
    mutating func addMultipartField(boundary: String, fieldName: String, fieldValue: String) {
        append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        append("\(fieldValue)".data(using: .utf8)!)
    }
}

extension URLResponse {
    var httpUrlResponse: HTTPURLResponse? { self as? HTTPURLResponse }
}

public extension Dictionary {
    var serialized: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

fileprivate extension URLRequest {
    mutating func addHeaders(_ header: Headers?) {
        var myIDFA = "0000-0000-00000-00000-0000"
        var strIDFV = "0000-0000-00000-00000-0000"
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            myIDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            strIDFV = (UIDevice.current.identifierForVendor?.uuidString)!
        }
        var headers = ["Accept" : "application/json",
                       "Content-Type" : "application/json",
                       "Device-Type" : "1",
                       "Device-Name" : UIDevice.current.localizedModel,
                       "App-Version" : (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!,
                       "Timezone" : TimeZone.current.identifier,
                       "IDFA": myIDFA,
                       "IDFV": strIDFV
        ]
        if let auth = (self as? AuthorizationProtocol) {
            headers["Authorization"] = "Bearer " + auth.sessionToken
            headers[auth.idType] = auth.id
        }
        if let header = header {
            headers = headers + header
        }
        headers.forEach { addValue($0.1, forHTTPHeaderField: $0.0) }
    }
}

public protocol AuthorizationProtocol {
    var sessionToken: String { get }
    var id: String { get }
    var idType: String { get }
}
