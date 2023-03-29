import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

final class AppCenterAPITests: XCTestCase {
    
    var sut: AppCenterAPI!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        mockNetworkService = MockNetworkService()
        sut = AppCenterAPI(httpService: mockNetworkService, accessToken: "abc123")
    }
    
    func test_newReleaseUpload() async throws {
        //Given
        mockNetworkService.sendResults.append(AppCenterAPI.NewReleaseUploadCreated(
            id: "0e04930c-1ac9-4a73-9340-ce68621bd7be",
            uploadDomain: URL(string: "https://file.appcenter.ms")!,
            token: "?sv=2019-02-02&sr=c&si=f2de7daf-5f12-4ede-85f9-a41733a20efd&sig=AUecLS8D3q6jEyWJQkiSx%2BtVT%2FafTBM9Xpxt5tyEP6Q%3D&se=2022-04-09T08%3A00%3A13Z&t=distribution",
            urlEncodedToken: "%3fsv%3d2019-02-02%26sr%3dc%26si%3df2de7daf-5f12-4ede-85f9-a41733a20efd%26sig%3dAUecLS8D3q6jEyWJQkiSx%252BtVT%252FafTBM9Xpxt5tyEP6Q%253D%26se%3d2022-04-09T08%253A00%253A13Z%26t%3ddistribution",
            packageAssetId: "f2de7daf-5f12-4ede-85f9-a41733a20efd"))
        
        //When
        _ = try await sut.newReleaseUpload(.init(ownerName: "ownerName", appName: "appName"))
        
        //Then
        XCTAssertEqual(mockNetworkService.sendCalls.count, 1)
        let sentRequest = mockNetworkService.sendCalls[0]
        XCTAssertEqual(sentRequest.httpMethod, "POST")
        XCTAssertEqual(sentRequest.url?.absoluteString, "https://api.appcenter.ms/v0.1/apps/ownerName/appName/uploads/releases")
        XCTAssertEqual(sentRequest.allHTTPHeaderFields, [
            "X-API-Token": "abc123"
        ])
        XCTAssertNil(sentRequest.httpBody)
    }
    
    func test_setReleaseUploadMetadata() async throws {
        //Given
        mockNetworkService.sendResults.append(
            AppCenterAPI.SetReleaseUploadMetadataResponse(
                id: "packageAssetId",
                blobPartitions: 1,
                chunkSize: 42,
                chunkList: [1,2,3,4,5],
                error: false,
                resumeRestart: false,
                statusCode: "Success"
            )
        )
        
        //When
        let releaseUpload = AppCenterAPI.NewReleaseUploadCreated(
            id: "0e04930c-1ac9-4a73-9340-ce68621bd7be",
            uploadDomain: URL(string: "https://file.appcenter.ms")!,
            token: "?sv=2019-02-02&sr=c&si=f2de7daf-5f12-4ede-85f9-a41733a20efd&sig=AUecLS8D3q6jEyWJQkiSx%2BtVT%2FafTBM9Xpxt5tyEP6Q%3D&se=2022-04-09T08%3A00%3A13Z&t=distribution",
            urlEncodedToken: "%3fsv%3d2019-02-02%26sr%3dc%26si%3df2de7daf-5f12-4ede-85f9-a41733a20efd%26sig%3dAUecLS8D3q6jEyWJQkiSx%252BtVT%252FafTBM9Xpxt5tyEP6Q%253D%26se%3d2022-04-09T08%253A00%253A13Z%26t%3ddistribution",
            packageAssetId: "f2de7daf-5f12-4ede-85f9-a41733a20efd"
        )
        _ = try await sut.setReleaseUploadMetadata(for: releaseUpload, fileName: "App.ipa", fileSize: 1)
        
        //Then
        XCTAssertEqual(mockNetworkService.sendCalls.count, 2)
        let sentRequest = mockNetworkService.sendCalls[0]
        XCTAssertEqual(sentRequest.httpMethod, "POST")
        XCTAssertEqual(sentRequest.url?.absoluteString, "https://file.appcenter.ms/upload/set_metadata/f2de7daf-5f12-4ede-85f9-a41733a20efd?content_type=application/octet-stream&file_name=App.ipa&file_size=1&token=?sv%3D2019-02-02%26sr%3Dc%26si%3Df2de7daf-5f12-4ede-85f9-a41733a20efd%26sig%3DAUecLS8D3q6jEyWJQkiSx%252BtVT%252FafTBM9Xpxt5tyEP6Q%253D%26se%3D2022-04-09T08%253A00%253A13Z%26t%3Ddistribution")
        XCTAssertEqual(sentRequest.allHTTPHeaderFields, [
            "Accept": "application/json",
            "X-API-Token": "abc123"
        ])
        XCTAssertNil(sentRequest.httpBody)
    }
    
    func test_updateReleaseUploadStatus() async throws {
        //Given
        let uploadId = "0e04930c-1ac9-4a73-9340-ce68621bd7be"
        mockNetworkService.sendResults.append(AppCenterAPI.UpdateReleaseStatusResponse(id: uploadId, uploadStatus: .uploadFinished))
        
        //When
        _ = try await sut.updateReleaseUploadStatus(.init(ownerName: "ownerName", appName: "appName", uploadId: uploadId, body: .init(uploadStatus: .uploadFinished)))
        
        //Then
        XCTAssertEqual(mockNetworkService.sendCalls.count, 1)
        let sentRequest = mockNetworkService.sendCalls[0]
        XCTAssertEqual(sentRequest.httpMethod, "PATCH")
        XCTAssertEqual(sentRequest.url?.absoluteString, "https://api.appcenter.ms/v0.1/apps/ownerName/appName/uploads/releases/0e04930c-1ac9-4a73-9340-ce68621bd7be")
        XCTAssertEqual(sentRequest.allHTTPHeaderFields, [
            "X-API-Token": "abc123",
            "Content-Type": "application/json"
        ])
        XCTAssertEqual(String(data: sentRequest.httpBody!, encoding: .utf8), #"{"upload_status":"uploadFinished"}"#)
    }
}
