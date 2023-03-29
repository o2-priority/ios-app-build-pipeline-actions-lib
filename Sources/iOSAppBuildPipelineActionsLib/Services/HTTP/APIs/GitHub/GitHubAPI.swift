import Foundation

public protocol GitHubAPIProtocol: API {
    
    func pullRequest(owner: String, repo: String, branchName: String) async throws -> [Git.PullRequest]
}

public extension GitHubAPIProtocol {
    
    var baseURLString: String { "https://api.github.com" }
}

public final class GitHubAPI: GitHubAPIProtocol, RequestConstructable {
    
    let httpService: HTTPServiceProtocol
    let accessToken: String
    
    public init(httpService: HTTPServiceProtocol, accessToken: String) {
        self.httpService = httpService
        self.accessToken = accessToken
    }
    
    public func pullRequest(owner: String, repo: String, branchName: String) async throws -> [Git.PullRequest] {
        let urlRequest: URLRequest = try constructRequest(with: PullRequests(owner: owner, repo: repo, branchName: branchName, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest)
    }
}
