import Foundation

public protocol ProcessInfoServiceProtocol {
    
    var environment: [String : String] { get }
}

public final class ProcessInfoService: ProcessInfoServiceProtocol {
    
    public static let shared: ProcessInfoServiceProtocol = ProcessInfoService()
    
    public var environment: [String : String] {
        ProcessInfo.processInfo.environment
    }
}
