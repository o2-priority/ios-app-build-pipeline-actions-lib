import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockAtlassianAPI: AtlassianAPIProtocol, API {
    
    var baseURLString = "https://mock.atlassian.net"
    
    var commentOnTicketCalls: [CommentOnTicketCall] = []
    
    var moveTicketToQAResults: [Result<Void, Error>] = []
    var commentOnTicketResults: [Result<Void, Error>] = []
    var postReleaseNotesResults: [Result<Atlassian.PageResponse, Error>] = []
    
    func moveTicketToQA(_ ticketNumber: String, jiraQAColumnId: String) async throws {
        try moveTicketToQAResults.removeFirst().get()
    }
    
    func commentOn(ticket: String, comment: Atlassian.Comment) async throws {
        commentOnTicketCalls.append(.init(ticket: ticket, comment: comment))
        try commentOnTicketResults.removeFirst().get()
    }
    
    func postReleaseNotes(_ page: Atlassian.Page) async throws -> Atlassian.PageResponse {
        try postReleaseNotesResults.removeFirst().get()
    }
    
    struct CommentOnTicketCall {
        let ticket: String, comment: Atlassian.Comment
    }
}
