import Foundation

extension BitriseAPI {
    
    public struct BuildTriggerParams: Codable {
        
        public struct BuildParameters: Codable {
//            let baseRepositoryUrl: String?
            let branch: String?
//            let branchDest: String?
//            let branchDestRepoOwner: String?
//            let branchRepoOwner: String?
//            let buildRequestSlug: String?
//            let commitHash: String?
//            let commitMessage: String?
//            let commitPaths: [CommitPaths]
//            let diffUrl: String?
            var environments: [Environment] = []
//            let headRepositoryUrl: String?
//            let pipelineId: String?
//            let pullRequestAuthor: String?
//            let pullRequestHeadBranch: String?
//            let pullRequestMergeBranch: String?
//            let pullRequestRepositoryUrl: String?
//            let skipGitStatusReport: Bool
//            let tag: String?
            let workflowId: String?
            
            public struct CommitPaths: Codable {
                let added: [String]
                let modified: [String]
                let removed: [String]
            }
            
            public struct Environment: Codable {
                var isExpand: Bool = false
                let mappedTo: String
                let value: String
            }
        }
        
        public struct HookInfo: Codable {
            var type = "bitrise"
        }
        
        let buildParams: BuildParameters
        var hookInfo: HookInfo = .init()
    }
    
    public struct BuildTriggerResponse: Codable {
        let buildNumber: Int
        let buildSlug: String
        let buildUrl: String
        let message: String
        let service: String
        let slug: String
        let status: String
        let triggeredWorkflow: String
    }
    
    public enum SPMCacheHit: String, CustomStringConvertible {
        case exact, partial, `false`
        
        public var description: String {
            switch self {
            case .exact:
                return "Exact cache hit for the first requested cache key."
            case .partial:
                return "Cache hit for a key other than the first."
            case .false:
                return "No cache hit, nothing was restored."
            }
        }
    }
}
