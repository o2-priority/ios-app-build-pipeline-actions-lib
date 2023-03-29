import Foundation

private let requestTimeout: TimeInterval = 10

public protocol API {
    
    var baseURLString: String { get }
}

protocol RequestConstructable {
    
    func constructRequest(with requestable: HTTPRequestable) throws -> URLRequest
}

extension API where Self: RequestConstructable {
    
    func constructRequest(with requestable: HTTPRequestable) throws -> URLRequest {
        guard let url = URL(string: (requestable.baseURLString ?? baseURLString) + requestable.path) else {
            throw ActionsError.malformedInput(description: requestable.path)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestable.method
        urlRequest.timeoutInterval = requestTimeout
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        if !requestable.body.isEmpty {
            urlRequest.httpBody = requestable.body
        }
        requestable.headers.forEach {
            urlRequest.addValue($1, forHTTPHeaderField: $0)
        }
        return urlRequest
    }
}
