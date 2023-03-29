import Foundation

public protocol ContentTypeOctetStream: ContentType {}

extension HTTPRequestable where Self: ContentTypeOctetStream {
    
    mutating public func addContentTypeHeader() {
        headers["Content-Type"] = "application/octet-stream"
    }
    
    mutating public func addContentLengthHeader() {
        headers["Content-Length"] = "\(body.count)"
    }
}
