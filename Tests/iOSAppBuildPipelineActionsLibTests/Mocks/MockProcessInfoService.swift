import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockProcessInfoService: ProcessInfoServiceProtocol {
    
    var environment: [String : String] = [:]
}
