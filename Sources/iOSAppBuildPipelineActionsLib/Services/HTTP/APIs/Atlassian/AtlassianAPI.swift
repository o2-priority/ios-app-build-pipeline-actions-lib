import Foundation

public protocol AtlassianAPIProtocol: API {
    
    func moveTicketToQA(_ ticketNumber: String, jiraQAColumnId: String) async throws
    func commentOn(ticket: String, comment: Atlassian.Comment) async throws
    func postReleaseNotes(_ page: Atlassian.Page) async throws -> Atlassian.ContentRepsonse
}

public final class AtlassianAPI: AtlassianAPIProtocol, RequestConstructable {
    
    public let baseURLString: String
    
    let httpService: HTTPServiceProtocol
    let credentials: Atlassian.Credentials
    
    public init(httpService: HTTPServiceProtocol, credentials: Atlassian.Credentials, baseURLString: String) {
        self.httpService = httpService
        self.credentials = credentials
        self.baseURLString = baseURLString
    }
    
    public func moveTicketToQA(_ ticketNumber: String, jiraQAColumnId: String) async throws {
        let body = Atlassian.TransitionBody(id: jiraQAColumnId)
        let requestable = try MoveTicketToQA(ticketNumber: ticketNumber, credentials: credentials, content: body)
        let urlRequest = try constructRequest(with: requestable)
        return try await httpService.send(urlRequest: urlRequest)
    }
    
    public func commentOn(ticket: String, comment: Atlassian.Comment) async throws {
        let requestable = try PostComment(ticketNumber: ticket,
                                          credentials: credentials,
                                          content: comment)
        let urlRequest = try constructRequest(with: requestable)
        return try await httpService.send(urlRequest: urlRequest)
    }
    
    public func postReleaseNotes(_ page: Atlassian.Page) async throws -> Atlassian.ContentRepsonse {
        let requestable = try PostReleaseNotes(credentials: credentials, content: page)
        let urlRequest = try constructRequest(with: requestable)
        return try await httpService.send(urlRequest: urlRequest)
    }
}
