import Foundation

public struct ReleaseNotesParameters {
    
    var environments: String
    var distributionMethod: String
    var confluenceSpaceId: String
    var confluenceParentPageId: String
    var pageTitle: String
    var gitHubOwner: String
    var gitHubRepo: String
    
    public init(environments: String,
                distributionMethod: String,
                confluenceSpaceId: String,
                confluenceParentPageId: String,
                pageTitle: String,
                gitHubOwner: String,
                gitHubRepo: String) throws
    {
        guard !environments.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !distributionMethod.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !confluenceSpaceId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !confluenceParentPageId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !pageTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ActionsError.malformedInput(description: "Input for release notes cannot be empty")
        }
        self.environments = environments
        self.distributionMethod = distributionMethod
        self.confluenceSpaceId = confluenceSpaceId
        self.confluenceParentPageId = confluenceParentPageId
        self.pageTitle = pageTitle
        self.gitHubOwner = gitHubOwner
        self.gitHubRepo = gitHubRepo
    }
}
