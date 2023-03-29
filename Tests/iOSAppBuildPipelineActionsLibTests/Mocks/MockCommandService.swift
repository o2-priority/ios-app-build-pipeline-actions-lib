import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockCommandService: CommandServiceProtocol {
    
    var result: [String] = [""]
    var resultsData : [Data] = []
    var error: CommandService.Error?
    var commandsReceived: [String] = []
    
    func run<T>(_ command: String, currentDirectory: URL?, textOutputStream: inout T) throws -> Data where T : TextOutputStream {
        if let error = error { throw error }
        commandsReceived.append(command)
        return resultsData.remove(at: 0)
    }
    
    func run<T>(_ command: String, currentDirectory: URL?, textOutputStream: inout T) throws -> String where T : TextOutputStream {
        if let error = error { throw error }
        commandsReceived.append(command)
        return result.remove(at: 0)
    }
    
    func run<T>(_ command: String, currentDirectory: URL?, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
}
