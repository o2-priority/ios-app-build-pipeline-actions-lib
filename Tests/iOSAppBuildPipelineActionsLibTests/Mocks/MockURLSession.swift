import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockURLSession: URLSessionProtocol {
    
    var results: [Result<(Data, URLResponse), Error>] = []
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try results.remove(at: 0).get()
    }
    
    func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        try results.remove(at: 0).get()
    }
    
    func upload(for request: URLRequest, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        try results.remove(at: 0).get()
    }
}
