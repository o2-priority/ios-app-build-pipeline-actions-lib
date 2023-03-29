import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockGitHubAPI: GitHubAPIProtocol, API {
    
    var pullRequestResults: [Result<[Git.PullRequest], Error>] = []

    func pullRequest(owner: String, repo: String, branchName: String) async throws -> [Git.PullRequest] {
        try pullRequestResults.removeFirst().get()
    }
}
