import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockBuildNumberAPI: BuildNumberAPIProtocol {
    
    var getNextBuildNumberResults: [Result<Int, Error>] = []
    
    func getNextBuildNumber(numberId: String) async throws -> Int {
        try getNextBuildNumberResults.removeFirst().get()
    }
}
