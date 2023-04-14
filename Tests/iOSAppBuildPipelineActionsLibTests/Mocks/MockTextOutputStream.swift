import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockTextOutputStream: RedactableTextOutputStream {
    
    var writes: [String] = []
    
    func write(_ string: String) {
        writes.append(string)
    }
    
    func redact(string: String) {
        
    }
}
