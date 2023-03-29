import Foundation

public protocol HTTPRequestable {
    
    var baseURLString: String? { get }
    var method: String { get }
    var body: Data { get }
    var path: String { get }
    var headers: [String: String] { get set }
}

public extension HTTPRequestable {
    
    var baseURLString: String? { nil }
    var body: Data { .init() }
}

public protocol Accept {
    mutating func addAcceptHeader()
}

public protocol ContentType {
    mutating func addContentTypeHeader()
}
