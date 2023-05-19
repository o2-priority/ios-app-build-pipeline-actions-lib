import Foundation

public struct Git {
    
    public struct PullRequest: Codable {
        let id: Int
        let html_url: String
    }
    
    public struct Branch: CustomStringConvertible {
        let name: String
        
        public var description: String {
            name
        }
    }
}

extension Git.Branch {
    
    func parseJiraTicketNumber() throws -> String {
        let components = name.components(separatedBy: "/")
        guard components.count > 2 else {
            throw ActionsError.wrongBranchNamingConvention
        }
        return components[1]
    }
    
    func parseReleaseVersions() throws -> (String, String) {
        let components = name.components(separatedBy: "/")
        if components.count != 4 {
            throw ActionsError.wrongBranchNamingConvention
        }
        return (components[2], components[3])
    }
}
