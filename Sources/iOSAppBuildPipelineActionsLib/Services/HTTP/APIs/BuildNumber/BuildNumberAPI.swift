import Foundation

public protocol BuildNumberAPIProtocol: API {
    
    func getNextBuildNumber(numberId: String) async throws -> Int
}

public extension BuildNumberAPIProtocol {
    
    //TODO: Update URL
    var baseURLString: String { "https://dev/null" }
}

public final class BuildNumberAPI: BuildNumberAPIProtocol, RequestConstructable {
    
    let httpService: HTTPServiceProtocol
    let accessToken: String
    
    public init(httpService: HTTPServiceProtocol, accessToken: String) {
        self.httpService = httpService
        self.accessToken = accessToken
    }
    
    public func getNextBuildNumber(numberId: String) async throws -> Int {
        let urlRequest = try constructRequest(with: BuildNumberAPI.GetNext(accessToken: accessToken, numberId: numberId))
        return try await httpService.send(urlRequest: urlRequest)
    }
}
