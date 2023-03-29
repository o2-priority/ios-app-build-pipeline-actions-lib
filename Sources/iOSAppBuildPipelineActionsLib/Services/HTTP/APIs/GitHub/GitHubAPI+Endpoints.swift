import Foundation

public struct PullRequests: HTTPRequestable {
    
    public var method: String
    public var path: String
    public var headers: [String : String] = [:]
    
    init(owner: String, repo: String, branchName: String, accessToken: String) {
        method = "GET"
        path = "/repos/\(owner)/\(repo)/pulls?head=\(owner):\(branchName)"
        headers["Authorization"] = "token \(accessToken)"
    }
}
