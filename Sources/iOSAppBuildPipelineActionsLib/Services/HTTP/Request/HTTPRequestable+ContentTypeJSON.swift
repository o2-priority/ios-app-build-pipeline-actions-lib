import Foundation

public protocol ContentTypeJSON: ContentType {
    
    associatedtype T: Encodable
    
    var jsonEncoder: JSONEncoder { get }
    var content: T { get }
}

extension HTTPRequestable where Self: ContentTypeJSON {
    
    public var body: Data {
        (try? jsonEncoder.encode(content)) ?? Data()
    }
    
    public mutating func addContentTypeHeader() {
        headers["Content-Type"] = "application/json"
    }
}

