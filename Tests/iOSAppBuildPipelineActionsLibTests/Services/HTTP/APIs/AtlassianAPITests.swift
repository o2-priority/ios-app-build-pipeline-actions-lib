import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

class AtlassianAPITests: XCTestCase {
    
    var atlassianAPI: AtlassianAPI!
    var mockNetworkService = MockNetworkService()
    
    override func setUp() {
        atlassianAPI = AtlassianAPI(httpService: mockNetworkService, credentials: Atlassian.Credentials(userName: "username", token: "token"), baseURLString: "https://example.atlassian.net")
    }
    
    //MARK: moveTicketToQA tests
    func test_moveTicketToQA_when_ticketNumber_has_illegal_character() async throws {
        //Given
        let ticketNumber = "�"
        
        //When
        do {
            try await atlassianAPI.moveTicketToQA(ticketNumber, jiraQAColumnId: "columnId")
            XCTFail("Should have thrown error")
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "/rest/api/3/issue/\(ticketNumber)/transitions?expand=transitions.fields"))
        }
    }
    
    func test_moveTicketToQA_when_ticketNumber_is_as_proper() async throws {
        //Given
        let ticketNumber = "PR-1234"
        mockNetworkService.sendResults = [()]
        
        //When
        do {
            try await atlassianAPI.moveTicketToQA(ticketNumber, jiraQAColumnId: "columnId")
        } catch {
            XCTFail("Shouldn't have thrown error")
        }
    }
    
    //MARK: commentOn tests
//    func test_commentOn_when_ticketNumber_has_illegal_character() async throws {
//        //Given
//        let ticketNumber = "�"
//        
//        //When
//        do {
//            try await atlassianAPI.commentOn(ticket: ticketNumber, comment: "comment")
//            XCTFail("Should have thrown error")
//        } catch {
//            //Then
//            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "/rest/api/2/issue/\(ticketNumber)/comment"))
//        }
//    }
    
//    func test_commentOn_when_ticketNumber_is_as_proper() async throws {
//        //Given
//        let ticketNumber = "PR-1234"
//        mockNetworkService.sendResults = [()]
//
//        //When
//        do {
//            try await atlassianAPI.commentOn(ticket: ticketNumber, comment: "comment")
//        } catch {
//            XCTFail("Shouldn't have thrown error")
//        }
//    }
    
    //MARK: postReleaseNotes tests
    func test_postReleaseNotes_when_ticketNumber_is_as_proper() async throws {
        //Given
        let body = try Atlassian.Page(spaceId: "sid", status: .current, title: "title", parentId: "pid", atlasDocFormat: .init(content: []))
        mockNetworkService.sendResults = [Atlassian.PageResponse(id: "0")]
        
        //When
        do {
            _ = try await atlassianAPI.postReleaseNotes(body)
        } catch {
            XCTFail("Shouldn't have thrown error")
        }
    }
}
