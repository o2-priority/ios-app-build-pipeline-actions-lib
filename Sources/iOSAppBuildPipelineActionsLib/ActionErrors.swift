import Foundation

public enum ActionsError: LocalizedError, Equatable {
    
    case wrongBranchNamingConvention
    case malformedInput(description: String)
    
    public var errorDescription: String? {
        switch self {
        case .wrongBranchNamingConvention:
            return "Wrong branch naming convention."
        case .malformedInput(let description):
            return "Malformed input: \(description)."
        }
    }
}
