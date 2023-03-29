import Foundation

public extension AtlassianAPI {

    struct MoveTicketToQA: HTTPRequestable, AuthorizationAtlassian, ContentTypeJSON {
        
        public var path: String
        public var method: String
        public var headers: [String : String] = [:]
        public var content: Atlassian.TransitionBody
        public let jsonEncoder = JSONEncoder()
        
        init(ticketNumber: String, credentials: Atlassian.Credentials, content: Atlassian.TransitionBody) throws {
            method = "POST"
            path = "/rest/api/3/issue/\(ticketNumber)/transitions?expand=transitions.fields"
            self.content = content
            try addAuthorizationHeader(credentials: credentials)
            addContentTypeHeader()
        }
    }

    struct PostComment: HTTPRequestable, AuthorizationAtlassian, ContentTypeJSON {
        
        public var path: String
        public var method: String
        public var headers: [String : String] = [:]
        public var content: Atlassian.Comment
        public let jsonEncoder = JSONEncoder()
        
        init(ticketNumber: String, credentials: Atlassian.Credentials, content: Atlassian.Comment) throws {
            method = "POST"
            path = "/rest/api/3/issue/\(ticketNumber)/comment"
            self.content = content
            try addAuthorizationHeader(credentials: credentials)
            addContentTypeHeader()
        }
    }

    /**
     https://developer.atlassian.com/cloud/confluence/rest/api-group-content/#api-wiki-rest-api-content-post
     */
    struct PostReleaseNotes: HTTPRequestable, AuthorizationAtlassian, ContentTypeJSON {
        
        public var path: String
        public var method: String
        public var headers: [String : String] = [:]
        public var content: Atlassian.Page
        public let jsonEncoder = JSONEncoder()
        
        init(credentials: Atlassian.Credentials, content: Atlassian.Page) throws {
            method = "POST"
            path = "/wiki/rest/api/content"
            self.content = content
            try addAuthorizationHeader(credentials: credentials)
            addContentTypeHeader()
        }
    }
}
