import Foundation

extension BitriseAPI {
    
    struct TriggerBuild: HTTPRequestable, ContentTypeJSON, AcceptJSON {
        
        let method: String
        let path: String
        var headers: [String : String] = [:]
        let content: BuildTriggerParams
        let jsonEncoder = JSONEncoder()
        
        init(appSlug: String, accessToken: String, buildTriggerParams: BuildTriggerParams) {
            method = "POST"
            path = "/apps/\(appSlug)/builds"
            headers["Authorization"] = accessToken
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            content = buildTriggerParams
            addContentTypeHeader()
        }
    }
}
