import Foundation
import Combine

public protocol HTTPServiceProtocol {
    
    func send(urlRequest: URLRequest) async throws
    func send<T>(urlRequest: URLRequest) async throws -> T where T: Decodable
    func send<T, D>(urlRequest: URLRequest, decoder: D) async throws -> T where T: Decodable, D: TopLevelDecoder, D.Input == Data
    func send<T, D, E>(urlRequest: URLRequest, decoder: D, errorType: E.Type) async throws -> T where T: Decodable, E: ErrorConvertible, D: TopLevelDecoder, D.Input == Data
    func upload(body: Data, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse)
    func upload(file: URL, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse)
}

public protocol ErrorConvertible: LocalizedError, Codable, Equatable {
    var name: String { get }
}

public final class HTTPService<T>: HTTPServiceProtocol where T: RedactableTextOutputStream {
    
    public struct ResponseError<E>: ErrorConvertible where E: ErrorConvertible {
        public var name = "HTTPService.ResponseError"
        let statusCode: Int
        let error: E
        
        public var errorDescription: String? {
            return "\(name) \(error.name): \(error.localizedDescription)"
        }
    }
    
    public struct ResponseUntypedError: ErrorConvertible {
        public var name = "HTTPService.ResponseUntypedError"
        let data: Data
        
        public var errorDescription: String? {
            return String(data: data, encoding: .utf8) ?? "HTTP response body not UTF8 encoded"
        }
    }
    
    private let urlSession: URLSessionProtocol
    private var textOutputStream: T
    
    public init(session: URLSessionProtocol, textOutputStream: T) {
        self.urlSession = session
        self.textOutputStream = textOutputStream
    }
    
    public func send(urlRequest: URLRequest) async throws {
        urlRequest.log(textOutputStream: &textOutputStream)
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        switch httpResponse.statusCode {
        case 400...599:
            throw ResponseError(statusCode: httpResponse.statusCode, error: ResponseUntypedError(data: data))
        default:
            break
        }
    }
    
    public func send<T>(urlRequest: URLRequest) async throws -> T where T : Decodable {
        try await send(urlRequest: urlRequest, decoder: JSONDecoder())
    }
    
    public func send<T, D>(urlRequest: URLRequest, decoder: D) async throws -> T where T: Decodable, D: TopLevelDecoder, D.Input == Data
    {
        try await send(urlRequest: urlRequest, decoder: decoder, errorType: ResponseUntypedError.self)
    }
    
    public func send<T, D, E>(urlRequest: URLRequest, decoder: D, errorType: E.Type) async throws -> T where T: Decodable, E: ErrorConvertible, D: TopLevelDecoder, D.Input == Data
    {
        urlRequest.log(textOutputStream: &textOutputStream)
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        switch httpResponse.statusCode {
        case 200...299:
            if let responseEntity: T = try? decoder.decode(T.self, from: data) {
                return responseEntity
            } else {
                throw ResponseError(statusCode: httpResponse.statusCode, error: ResponseUntypedError(data: data))
            }
        default:
            if let errorEntity: E = try? decoder.decode(E.self, from: data) {
                throw ResponseError(statusCode: httpResponse.statusCode, error: errorEntity)
            } else {
                throw ResponseError(statusCode: httpResponse.statusCode, error: ResponseUntypedError(data: data))
            }
        }
    }
    
    public func upload(body: Data, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse) {
        urlRequest.log(textOutputStream: &textOutputStream)
        return try await urlSession.upload(for: urlRequest, from: body, delegate: delegate)
    }
    
    public func upload(file: URL, urlRequest: URLRequest, delegate: URLSessionTaskDelegate) async throws -> (Data, URLResponse) {
        urlRequest.log(textOutputStream: &textOutputStream)
        return try await urlSession.upload(for: urlRequest, fromFile: file, delegate: delegate)
    }
}
