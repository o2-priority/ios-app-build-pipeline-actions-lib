import XCTest

@testable import iOSAppBuildPipelineActionsLib

final class VersionTests: XCTestCase {

    func testVersionMatchesGitTag() throws {
        //Given
        let textOutputStream = MockRedactableTextOutputStream()
        let commandService = CommandService()
        let repoDir = String(URL(fileURLWithPath: #file)
            .pathComponents
            .prefix(while: { $0 != "Tests" })
            .joined(separator: "/")
            .dropFirst())
        let gitService = GitService(commandService: commandService,
                                    repoDir: .init(repoDir),
                                    textOutputStream: textOutputStream)
        let version: String = try gitService.git("--no-pager tag --points-at HEAD").trimmingCharacters(in: .whitespacesAndNewlines)
        textOutputStream.writes.removeAll()
        let versionCommand = Version(textOutputStream: textOutputStream)
        
        //When
        versionCommand.version()
        
        //Then
        XCTAssertEqual(textOutputStream.writes, [
            "", "\(version)", "\n"
        ])
    }
}
