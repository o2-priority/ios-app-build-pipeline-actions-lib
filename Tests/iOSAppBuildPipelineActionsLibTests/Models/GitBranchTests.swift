import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

class GitBranchTests: XCTestCase {
    
    //MARK: - parseJiraTicketNumber
    func test_parseJiraTicketNumber_returns_ticket_number_if_in_right_format() async throws {
        //Given
        let branch = Git.Branch(name: "feature/PR-1656/branchName")
        
        //When
        let ticketNumber = try? branch.parseJiraTicketNumber()
        
        //Then
        XCTAssertEqual(ticketNumber, "PR-1656")
    }
    
    func test_parseJiraTicketNumber_should_not_return_ticket_number_if_not_in_right_format() async throws {
        //Given
        let branch = Git.Branch(name: "feature/branchName")
        
        //When
        let ticketNumber = try? branch.parseJiraTicketNumber()
        
        //Then
        XCTAssertNil(ticketNumber)
    }
}
