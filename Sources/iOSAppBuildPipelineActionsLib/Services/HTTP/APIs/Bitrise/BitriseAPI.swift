import Foundation

public protocol BitriseAPIProtocol: API {
    
    func triggerBuild(_: BitriseAPI.BuildTriggerParams) async throws -> BitriseAPI.BuildTriggerResponse
}

public extension BitriseAPIProtocol {
    
    var baseURLString: String { "https://api.bitrise.io/v0.1" }
}

public final class BitriseAPI: BitriseAPIProtocol, RequestConstructable {
    
    private let httpService: HTTPServiceProtocol
    private let accessToken: String
    private let appSlug: String
    private let jsonDecoder = JSONDecoder()
    
    public init(httpService: HTTPServiceProtocol, accessToken: String, appSlug: String) {
        self.httpService = httpService
        self.accessToken = accessToken
        self.appSlug = appSlug
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func triggerBuild(_ buildTriggerParams: BuildTriggerParams) async throws -> BuildTriggerResponse {
        let urlRequest: URLRequest = try constructRequest(with: TriggerBuild(appSlug: appSlug, accessToken: accessToken, buildTriggerParams: buildTriggerParams))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: BitriseAPI.Error.self)
    }
}
