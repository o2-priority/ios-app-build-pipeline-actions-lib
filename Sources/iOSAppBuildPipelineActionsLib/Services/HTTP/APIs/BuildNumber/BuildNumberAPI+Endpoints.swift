import Foundation

extension BuildNumberAPI {
    
    struct GetNext: HTTPRequestable, ContentTypeURI {
        
        var method: String
        var path: String
        var headers: [String : String] = [:]
        let content: [URLQueryItem]
        
        init(accessToken: String, numberId: String) {
            method = "POST"
            path = "/number/next"
            headers["Authorization"] = accessToken
            content = [.init(name: "number_id", value: numberId)]
            addContentTypeHeader()
        }
    }
}
