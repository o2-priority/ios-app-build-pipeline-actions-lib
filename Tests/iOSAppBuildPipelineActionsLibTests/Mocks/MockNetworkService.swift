import Foundation
import Combine

@testable import iOSAppBuildPipelineActionsLib

final class MockNetworkService: HTTPServiceProtocol {
    
    var sendResults: [Any] = []
    var uploadResults: [Result<(Data, URLResponse),Error>] = []
    
    var sendCalls: [URLRequest] = []
    
    func send(urlRequest: URLRequest) async throws {
        sendCalls.append(urlRequest)
        let result = sendResults.removeFirst()
        if let error = result as? Error {
            throw error
        }
    }
    
    func send<T>(urlRequest: URLRequest) async throws -> T where T : Decodable
    {
        sendCalls.append(urlRequest)
        return try await send(urlRequest: urlRequest, decoder: JSONDecoder())
    }
    
    func send<T, D>(urlRequest: URLRequest, decoder: D) async throws -> T where T : Decodable, D : TopLevelDecoder, D.Input == Data
    {
        sendCalls.append(urlRequest)
        return try await send(urlRequest: urlRequest, decoder: decoder, errorType: String.self)
    }
    
    func send<T, D, E>(urlRequest: URLRequest, decoder: D, errorType: E.Type) async throws -> T where T : Decodable, D : TopLevelDecoder, E : Decodable, D.Input == Data
    {
        sendCalls.append(urlRequest)
        let result = sendResults.removeFirst()
        if let error = result as? Error {
            throw error
        } else {
            return result as! T
        }
    }
    
    func upload(body: Data, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse) {
        try uploadResults.removeFirst().get()
    }
    
    func upload(file: URL, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse) {
        try uploadResults.removeFirst().get()
    }
}
