import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

final class HTTPServiceTests: XCTestCase {
    
    typealias HTTPServiceForTesting = HTTPService<MockRedactableTextOutputStream>
    
    struct ExampleJSON: Codable {
        let value: String
    }
    
    var httpService: HTTPServiceProtocol!
    var mockSession: MockURLSession!
    var textOutputStream = MockRedactableTextOutputStream()
    let mockGitHubPullRequestsJson = """
    [
        {
            "id": 1,
            "html_url": "www.google.com"
        },
        {
            "id": 2,
            "html_url": "www.google.com"
        }
    ]
    """
    let mockPage = Atlassian.Page(title: "title1", space: "space1", ancestor: "ancestor1", content: "content1", representation: .storage)
    let mockCredentials = Atlassian.Credentials(userName: "user1", token: "token1")
    let mockURL = URL(string: "www.google.com")!
    let mockURLRequest = URLRequest(url: URL(string: "www.google.com")!)
    let jsonDecoder = JSONDecoder()
    
    override func setUp() {
        mockSession = MockURLSession()
        httpService = HTTPService(session: mockSession, textOutputStream: textOutputStream)
    }
    
    private func buildResponse(url: URL = URL(string: "www.google.com")!, statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url,
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    // MARK: send
    func test_send_200() async throws {
        //Given
        mockSession.results = [.success((mockGitHubPullRequestsJson.data(using: .utf8)!, buildResponse(statusCode: 200)))]

        //When
        try await httpService.send(urlRequest: mockURLRequest)
    }
    
    func test_send_404() async throws {
        do {
            //Given
            mockSession.results = [.success((Data(), buildResponse(statusCode: 404)))]
            //When
            try await httpService.send(urlRequest: mockURLRequest)
        } catch {
            //Then
            XCTAssertEqual(error as? HTTPServiceForTesting.ResponseError, .init(statusCode: 404, error: HTTPServiceForTesting.ResponseUntypedError(data: .init())))
        }
    }
    
    // MARK: send<T: Decodable>
    
    func test_send_decodable_200() async throws {
        do {
            //Given
            mockSession.results = [.success((mockGitHubPullRequestsJson.data(using: .utf8)!, buildResponse(statusCode: 200)))]

            //When
            let pullRequests: [Git.PullRequest] = try await httpService.send(urlRequest: mockURLRequest)
            //Then
            XCTAssertEqual(pullRequests.count, 2)
        } catch {
            XCTFail("Shouldn't have received a failure")
        }
    }
    
    func test_send_decodable_404() async throws {
        do {
            //Given
            mockSession.results = [.success((Data(), buildResponse(statusCode: 404)))]

            //When
            let _: ExampleJSON = try await httpService.send(urlRequest: mockURLRequest)
            XCTFail("Shouldn't have received a success")
        } catch {
            //Then
            XCTAssertEqual(error as? HTTPServiceForTesting.ResponseError, .init(statusCode: 404, error: HTTPServiceForTesting.ResponseUntypedError(data: .init())))
        }
    }
    
    func test_send_decodable_responseBodyEmpty() async throws {
        do {
            //Given
            mockSession.results = [.success((Data(), buildResponse(statusCode: 200)))]

            //When
            let _: ExampleJSON = try await httpService.send(urlRequest: mockURLRequest)
            XCTFail("Shouldn't have received a success")
        } catch {
            
        }
    }
    
    func test_send_decodable_responseBodyInvalidJSON() async throws {
        do {
            //Given
            mockSession.results = [.success(("{".data(using: .utf8)!, buildResponse(statusCode: 200)))]

            //When
            let _: ExampleJSON = try await httpService.send(urlRequest: mockURLRequest)
            XCTFail("Shouldn't have received a success")
        } catch {
            //Then
            XCTAssertEqual(error as? HTTPServiceForTesting.ResponseError, .init(statusCode: 200, error: HTTPServiceForTesting.ResponseUntypedError(data: "{".data(using: .utf8)!)))
        }
    }
    
    // MARK: send<T, D, E>(urlRequest: URLRequest, decoder: D, errorType: E.Type)
    
    func test_send_tde_responseBodyWithError() async throws {
        //Given
        do {
            let data = try JSONEncoder().encode(AppCenterAPI.Error(message: "BadRequest"))
            mockSession.results = [.success((data, buildResponse(statusCode: 400)))]

            //When
            let _: ExampleJSON = try await httpService.send(urlRequest: mockURLRequest, decoder: jsonDecoder, errorType: AppCenterAPI.Error.self)
            XCTFail("Shouldn't have received a success")
        } catch {
            //Then
            XCTAssertEqual("HTTPService.ResponseError AppCenterAPI.Error: BadRequest", error.localizedDescription)
        }
    }
}
