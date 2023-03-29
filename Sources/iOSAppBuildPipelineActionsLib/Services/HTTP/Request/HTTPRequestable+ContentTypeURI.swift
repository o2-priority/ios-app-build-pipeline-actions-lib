import Foundation

public protocol ContentTypeURI: ContentType {
    
    var content: [URLQueryItem] { get }
}

extension HTTPRequestable where Self: ContentTypeURI {
    
    public var body: Data {
        var urlParser = URLComponents()
        urlParser.queryItems = content
        return urlParser.percentEncodedQuery?.data(using: .utf8) ?? Data()
    }
    
    mutating func addContentTypeHeader() {
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    }
}
