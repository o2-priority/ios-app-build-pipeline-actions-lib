import Foundation

public extension AppCenterAPI {
    
    struct Error: ErrorConvertible {
        public var name = "AppCenterAPI.Error"
        let message: String
        
        public var errorDescription: String? {
            return message
        }
    }
    
    struct ErrorWithCode: ErrorConvertible {
        public var name = "AppCenterAPI.ErrorWithCode"
        let code: ErrorCode
        let message: String
        
        public var errorDescription: String? {
            return message
        }
    }
    
    enum ErrorCode: String, Codable, Equatable {
        case BadRequest, Conflict, NotAcceptable, NotFound, InternalServerError, Unauthorized, TooManyRequests
    }
}
