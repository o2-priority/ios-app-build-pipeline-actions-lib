import Foundation

public protocol SlackAPIProtocol: API {
    
    func incomingWebHook(url: URL, blocks: [SlackAPI.Block]) async throws
}

public extension SlackAPIProtocol {
    
    var baseURLString: String { "" }
}

public final class SlackAPI: SlackAPIProtocol, RequestConstructable {
    
    let httpService: HTTPServiceProtocol
    
    public init(httpService: HTTPServiceProtocol) {
        self.httpService = httpService
    }
    
    public func incomingWebHook(url: URL, blocks: [Block]) async throws {
        let urlRequest: URLRequest = try constructRequest(with: SlackAPI.IncomingWebHook(content: .init(blocks: blocks), webhookURL: url))
        return try await httpService.send(urlRequest: urlRequest)
    }
}
