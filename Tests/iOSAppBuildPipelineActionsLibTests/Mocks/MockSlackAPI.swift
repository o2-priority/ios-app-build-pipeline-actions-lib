import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockSlackAPI: SlackAPIProtocol {
    
    var results: [Result<String, Error>] = []
    
    func incomingWebHook(url: URL, blocks: [SlackAPI.Block]) async throws {
        
    }
}
