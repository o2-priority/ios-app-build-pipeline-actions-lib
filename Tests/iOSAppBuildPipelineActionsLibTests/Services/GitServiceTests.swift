import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

class GitServiceTests: XCTestCase {
    
    var gitService: GitService<MockTextOutputStream>!
    var commandService: MockCommandService!
    
    override func setUp() {
        commandService = MockCommandService()
        gitService = GitService(commandService: commandService, repoDir: "dir", textOutputStream: MockTextOutputStream())
    }
    
    //MARK: fetchCurrentBranch tests
    func test_fetchCurrentBranch_when_command_service_throws_an_error() async throws {
        //Given
        commandService.error = CommandService.Error(command: "", message: "")
        
        //When
        do {
            _ = try gitService.fetchCurrentBranch()
            XCTFail("Should have thrown error")
        } catch {
            //Then
            XCTAssertEqual(error as? CommandService.Error, commandService.error)
        } 
    }
    
    func test_fetchCurrentBranch_when_command_service_returns_proper_response() async throws {
        //Given
        commandService.result = ["feature/PR-1234/branchName"]
        
        //When
        let gitBranch = try gitService.fetchCurrentBranch()
        
        //Then
        XCTAssertEqual(gitBranch.name, "feature/PR-1234/branchName")
        XCTAssertEqual(commandService.commandsReceived, [#"git --git-dir="dir/.git" --work-tree=dir branch --show-current"#])
    }
    
    //MARK: fetchAncestryPathGitLog tests
    func test_fetchAncestryPathGitLog_when_command_service_throws_an_error() async throws {
        //Given
        commandService.error = CommandService.Error(command: "", message: "")
        
        //When
        do {
            _ = try gitService.fetchAncestryPathGitLog(comparisonTag: "")
            XCTFail("Should have thrown error")
        } catch {
            //Then
            XCTAssertEqual(error as? CommandService.Error, commandService.error)
        } 
    }
    
    func test_fetchAncestryPathGitLog_no_common_ancestor_found() async throws {
        //Given
        commandService.result = ["release/6.3.5/6.3.4", "", "", "", "", "gitLog"]
        
        //When
        do {
            _ = try gitService.fetchAncestryPathGitLog(comparisonTag: "6.3.4")
            XCTFail("Should have thrown error")
        } catch {
            //Then
            XCTAssertEqual(error as? CommandService.Error, .init(command: "git merge-base 6.3.4 release/6.3.5/6.3.4", message: "No common ancestor found between `6.3.4` and `release/6.3.5/6.3.4`"))
        } 
    }
    
    func test_fetchAncestryPathGitLog_when_command_service_returns_proper_response() async throws {
        //Given
        commandService.result = ["release/6.3.5/6.3.4", "", "", "", "commonAncestor", "123456", "gitLog"]
        
        //When
        let ancestryPathGitLog = try gitService.fetchAncestryPathGitLog(comparisonTag: "6.3.4")
        XCTAssertEqual(commandService.commandsReceived, [
            #"git --git-dir="dir/.git" --work-tree=dir branch --show-current"#,
            #"git --git-dir="dir/.git" --work-tree=dir fetch origin tag 6.3.4"#,
            #"git --git-dir="dir/.git" --work-tree=dir checkout tags/6.3.4"#,
            #"git --git-dir="dir/.git" --work-tree=dir checkout release/6.3.5/6.3.4"#,
            #"git --git-dir="dir/.git" --work-tree=dir merge-base tags/6.3.4 release/6.3.5/6.3.4"#,
            #"git --git-dir="dir/.git" --work-tree=dir --no-pager rev-list --ancestry-path commonAncestor..release/6.3.5/6.3.4"#,
            #"git --git-dir="dir/.git" --work-tree=dir --no-pager log --oneline 123456 -n 1"#])
        //Then
        XCTAssertEqual(ancestryPathGitLog, "gitLog")
    }
}
