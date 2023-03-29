import Foundation

public protocol AppCenterAPIProtocol: API {
    
    func newReleaseUpload(_: AppCenterAPI.NewReleaseUploadParameters) async throws -> AppCenterAPI.NewReleaseUploadCreated
    func setReleaseUploadMetadata(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated, fileName: String, fileSize: Int) async throws -> AppCenterAPI.SetReleaseUploadMetadataResponse
    func releaseUploadChunk(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated, chunkNumber: Int, body: Data, progress: @escaping (Double) -> Void) async throws
    func finishReleaseUpload(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated) async throws
    func updateReleaseUploadStatus(_ parameters: AppCenterAPI.UpdateReleaseStatusParameters) async throws -> AppCenterAPI.UpdateReleaseStatusResponse
    func getUploadRelease(_ parameters: AppCenterAPI.GetUploadReleaseParameters) async throws -> AppCenterAPI.GetUploadReleaseResponse
    func patchRelease(_ parameters: AppCenterAPI.PatchReleaseParameters) async throws -> AppCenterAPI.PatchReleaseResponse
    func beginSymbolsUpload(_ parameters: AppCenterAPI.BeginSymbolsUploadParameters) async throws -> AppCenterAPI.BeginSymbolsUploadResponse
    func symbolsUpload(file: URL, uploadUrl: URL, progress: @escaping (Double) -> Void) async throws
    func finishSymbolsUpload(_ parameters: AppCenterAPI.FinishSymbolsUploadParameters) async throws -> AppCenterAPI.FinishSymbolsUploadResponse
}

public extension AppCenterAPIProtocol {
    
    var baseURLString: String { "https://api.appcenter.ms" }
}

public final class AppCenterAPI: AppCenterAPIProtocol, RequestConstructable {
    
    private let httpService: HTTPServiceProtocol
    private let accessToken: String
    private let jsonDecoder = JSONDecoder()
    
    public init(httpService: HTTPServiceProtocol, accessToken: String) {
        self.httpService = httpService
        self.accessToken = accessToken
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func newReleaseUpload(_ parameters: NewReleaseUploadParameters) async throws -> NewReleaseUploadCreated {
        let urlRequest = try constructRequest(with: NewReleaseUploadRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.ErrorWithCode.self)
    }
    
    public func setReleaseUploadMetadata(for releaseUpload: NewReleaseUploadCreated, fileName: String, fileSize: Int) async throws -> SetReleaseUploadMetadataResponse {
        let urlRequest = try constructRequest(with: SetReleaseUploadMetadataRequest(releaseUpload: releaseUpload, fileName: fileName, fileSize: fileSize, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder)
    }
    
    public func releaseUploadChunk(for releaseUpload: NewReleaseUploadCreated, chunkNumber: Int, body: Data, progress: @escaping (Double) -> Void) async throws {
        let urlRequest = try constructRequest(with: ReleaseUploadChunkRequest(releaseUpload: releaseUpload, blockNumber: chunkNumber, content: body))
        let delegate = UploadDelegate(progress: progress)
        _ = try await httpService.upload(body: body, urlRequest: urlRequest, delegate: delegate)
    }
    
    public func finishReleaseUpload(for releaseUpload: NewReleaseUploadCreated) async throws {
        let urlRequest = try constructRequest(with: FinishReleaseUploadRequest(releaseUpload: releaseUpload, accessToken: accessToken))
        try await httpService.send(urlRequest: urlRequest)
    }
    
    public func updateReleaseUploadStatus(_ parameters: UpdateReleaseStatusParameters) async throws -> UpdateReleaseStatusResponse {
        let urlRequest = try constructRequest(with: UpdateReleaseStatusRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.ErrorWithCode.self)
    }
    
    public func getUploadRelease(_ parameters: GetUploadReleaseParameters) async throws -> GetUploadReleaseResponse {
        let urlRequest = try constructRequest(with: GetUploadReleaseRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.ErrorWithCode.self)
    }
    
    public func patchRelease(_ parameters: PatchReleaseParameters) async throws -> PatchReleaseResponse {
        let urlRequest = try constructRequest(with: PatchReleaseRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.ErrorWithCode.self)
    }
    
    public func beginSymbolsUpload(_ parameters: BeginSymbolsUploadParameters) async throws -> BeginSymbolsUploadResponse {
        let urlRequest = try constructRequest(with: BeginSymbolsUploadRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.Error.self)
    }
    
    public func symbolsUpload(file: URL, uploadUrl: URL, progress: @escaping (Double) -> Void) async throws {
        let urlRequest = try constructRequest(with: SymbolsUploadRequest(uploadUrl: uploadUrl))
        let delegate = UploadDelegate(progress: progress)
        _ = try await httpService.upload(file: file, urlRequest: urlRequest, delegate: delegate)
        if let error = delegate.error { throw error }
    }
    
    public func finishSymbolsUpload(_ parameters: FinishSymbolsUploadParameters) async throws -> FinishSymbolsUploadResponse {
        let urlRequest = try constructRequest(with: FinishSymbolsUploadRequest(parameters: parameters, accessToken: accessToken))
        return try await httpService.send(urlRequest: urlRequest, decoder: jsonDecoder, errorType: AppCenterAPI.Error.self)
    }
}

final class UploadDelegate: NSObject, URLSessionTaskDelegate {
    
    private let progress: (Double) -> Void
    private (set) var error: Error?
    
    init(progress: @escaping (Double) -> Void) {
        self.progress = progress
        super.init()
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64)
    {
        progress(task.progress.fractionCompleted)
    }
    
    public func urlSession(_ session: URLSession,
                            task: URLSessionTask,
                            didCompleteWithError error: Error?)
    {
        self.error = error
    }
}
