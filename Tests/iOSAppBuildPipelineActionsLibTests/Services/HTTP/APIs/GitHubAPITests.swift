import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

class GitHubAPITests: XCTestCase {
    
    var gitHubAPI: GitHubAPI!
    var mockNetworkService = MockNetworkService()
    
    override func setUp() {
        gitHubAPI = GitHubAPI(httpService: mockNetworkService, accessToken: "accessToken")
    }
    
    //MARK: pullRequest tests
    func test_pullRequest_when_branch_name_has_illegal_character() async throws {
        //Given
        let branchName = "�"
        
        //When
        do {
            _ = try await gitHubAPI.pullRequest(owner: "owner", repo: "repo", branchName: branchName)
            XCTFail("Should have thrown error")
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "/repos/owner/repo/pulls?head=owner:�"))
        }
    }
    
    func test_pullRequest_when_branch_name_is_as_proper() async throws {
        //Given
        let branchName = "branchName"
        mockNetworkService.sendResults = [[Git.PullRequest(id: 1, html_url: "")]]
        
        //When
        do {
            _ = try await gitHubAPI.pullRequest(owner: "owner", repo: "repo", branchName: branchName)
            //Then
        } catch {
            XCTFail("Shouldn't have thrown error")
        }
    }
}
