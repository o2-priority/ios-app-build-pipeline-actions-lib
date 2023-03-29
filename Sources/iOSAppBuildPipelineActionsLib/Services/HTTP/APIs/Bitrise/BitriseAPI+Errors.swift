import Foundation

extension BitriseAPI {
    
    struct Error: ErrorConvertible {
        public var name = "BitriseAPI.Error"
        let message: String
    }
}
