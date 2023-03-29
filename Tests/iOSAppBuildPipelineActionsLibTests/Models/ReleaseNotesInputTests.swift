import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

class ReleaseNotesInputTests: XCTestCase {
    
    //MARK: - init
    func test_init_should_throw_error_if_environment_is_empty() async throws {
        //When
        do {
            _ = try ReleaseNotesParameters(environments: "", distributionMethod: "dist", confluenceParentPageId: "id", pageTitle: "title", gitHubOwner: "owner", gitHubRepo: "repo")
            XCTFail()
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "Input for release notes cannot be empty"))
        }
    }
    
    func test_init_should_throw_error_if_distributionMethod_is_empty() async throws {
        //When
        do {
            _ = try ReleaseNotesParameters(environments: "env", distributionMethod: "", confluenceParentPageId: "id", pageTitle: "title", gitHubOwner: "owner", gitHubRepo: "repo")
            XCTFail()
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "Input for release notes cannot be empty"))
        }
    }
    
    func test_init_should_throw_error_if_confluenceParentPageId_is_empty() async throws {
        //When
        do {
            _ = try ReleaseNotesParameters(environments: "env", distributionMethod: "dist", confluenceParentPageId: "", pageTitle: "title", gitHubOwner: "owner", gitHubRepo: "repo")
            XCTFail()
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "Input for release notes cannot be empty"))
        }
    }
    
    func test_init_should_throw_error_if_pageTitle_is_empty() async throws {
        //When
        do {
            _ = try ReleaseNotesParameters(environments: "env", distributionMethod: "dist", confluenceParentPageId: "id", pageTitle: "", gitHubOwner: "owner", gitHubRepo: "repo")
            XCTFail()
        } catch {
            //Then
            XCTAssertEqual(error as? ActionsError, ActionsError.malformedInput(description: "Input for release notes cannot be empty"))
        }
    }
    
    func test_init_should_return_valid_object_if_valid_input() async throws {
        //When
        do {
            let input = try ReleaseNotesParameters(environments: "env", distributionMethod: "dist", confluenceParentPageId: "id", pageTitle: "title", gitHubOwner: "owner", gitHubRepo: "repo")
            //Then
            XCTAssertNotNil(input)
        } catch {
            XCTFail()
        }
    }
}
