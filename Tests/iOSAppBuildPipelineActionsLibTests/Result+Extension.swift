import Foundation

extension Result {
    
    func get() throws -> Success {
        switch self {
        case let .success(success):
            return success
        case let .failure(error):
            throw error
        }
    }
}
