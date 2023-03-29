import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockGitService: GitServiceProtocol {
    
    var fetchBranchResult: Result<Git.Branch, Error> = .failure(mockError)
    var fetchGitLogResult: Result<String, Error> = .failure(mockError)
    var isWorkingDirectoryCleanResult: Result<Bool, Error> = .failure(mockError)
    
    func commit(subject: String, body: String?) throws {
        
    }
    
    func fetchCurrentBranch() throws -> Git.Branch {
        try fetchBranchResult.get()
    }
    
    func fetchAncestryPathGitLog(comparisonTag: String) throws -> String {
        try fetchGitLogResult.get()
    }
    
    func isWorkingDirectoryClean() throws -> Bool {
        try isWorkingDirectoryCleanResult.get()
    }
    
    func push(remote: String, branch: String) throws {
        
    }
}
