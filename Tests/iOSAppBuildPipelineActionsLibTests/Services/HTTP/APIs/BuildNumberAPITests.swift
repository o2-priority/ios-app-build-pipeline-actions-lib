import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

final class BuildNumberAPITests: XCTestCase {
    
    var buildNumberAPI: BuildNumberAPI!
    var mockNetworkService = MockNetworkService()
    
    override func setUp() {
        buildNumberAPI = BuildNumberAPI(httpService: mockNetworkService, accessToken: "abc123")
    }
    
    func test_getNextBuildNumber() async throws {
        //Given
        let numberId = "com.apple"
        mockNetworkService.sendResults.append(1)
        
        //When
        _ = try await buildNumberAPI.getNextBuildNumber(numberId: numberId)
        //Then
        XCTAssertEqual(mockNetworkService.sendCalls.count, 3)
        let sentRequest = mockNetworkService.sendCalls[0]
        XCTAssertEqual(sentRequest.url?.absoluteString, "https://dev/null/number/next")
        XCTAssertEqual(sentRequest.allHTTPHeaderFields, [
            "Authorization": "abc123",
            "Content-Type": "application/x-www-form-urlencoded",
        ])
        XCTAssertEqual(String(data: sentRequest.httpBody!, encoding: .utf8), "number_id=com.apple")
    }
}
