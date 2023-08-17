import Foundation

extension DecodingError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let message: String
        switch self {
        case let .dataCorrupted(context):
            message = context.debugDescription
        case let .keyNotFound(key, context):
            message = "Key '\(key.stringValue)' not found at codingPath \(context.codingPath.map { $0.stringValue }). \(context.debugDescription)"
        case let .valueNotFound(value, context):
            message = "Value '\(value)' not found at codingPath \(context.codingPath.map { $0.stringValue }). \(context.debugDescription)"
        case let .typeMismatch(type, context):
            message = "Type '\(type)' mismatch at codingPath \(context.codingPath.map { $0.stringValue }). \(context.debugDescription)"
        default:
            message = "Unsupported DecodingError \(self)"
        }
        return message
    }
}
