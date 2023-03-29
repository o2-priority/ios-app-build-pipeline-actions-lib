import Foundation

extension SlackAPI {
    
    struct IncomingWebHook: HTTPRequestable, ContentTypeJSON {
        
        struct Content: Encodable {
            let blocks: [Block]
        }
        
        let baseURLString: String?
        let method: String
        let path: String
        var headers: [String : String] = [:]
        let content: Content
        let jsonEncoder = JSONEncoder()
        
        init(content: Content, webhookURL: URL) {
            baseURLString = webhookURL.absoluteString
            method = "POST"
            path = ""
            self.content = content
            addContentTypeHeader()
        }
    }
}

//public protocol HasSlackEncodedBody {
//
//    associatedtype T: Encodable
//    var content: T { get }
//}
//
//extension HTTPRequestable where Self: HasSlackEncodedBody {
//
//    public var body: Data? {
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.
//        return try? jsonEncoder.encode(content)
//    }
//}
