import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockAppCenterAPI: AppCenterAPIProtocol, API {
    
    var newReleaseUploadResults: [Result<AppCenterAPI.NewReleaseUploadCreated, Error>] = []
    var setReleaseUploadMetadataResults: [Result<AppCenterAPI.SetReleaseUploadMetadataResponse, Error>] = []
    var releaseUploadChunkResults: [Result<Void, Error>] = []
    var finishReleaseUploadResults: [Result<Void, Error>] = []
    var updateReleaseUploadStatusResults: [Result<AppCenterAPI.UpdateReleaseStatusResponse, Error>] = []
    var getUploadReleaseResults: [Result<AppCenterAPI.GetUploadReleaseResponse, Error>] = []
    var patchReleaseResults: [Result<AppCenterAPI.PatchReleaseResponse, Error>] = []
    var beginSymbolsUploadResults: [Result<AppCenterAPI.BeginSymbolsUploadResponse, Error>] = []
    var finishSymbolsUploadResults: [Result<AppCenterAPI.FinishSymbolsUploadResponse, Error>] = []
    
    func newReleaseUpload(_: AppCenterAPI.NewReleaseUploadParameters) async throws -> AppCenterAPI.NewReleaseUploadCreated {
        try newReleaseUploadResults.removeFirst().get()
    }
    
    func setReleaseUploadMetadata(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated, fileName: String, fileSize: Int) async throws -> AppCenterAPI.SetReleaseUploadMetadataResponse {
        try setReleaseUploadMetadataResults.removeFirst().get()
    }
    
    func releaseUploadChunk(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated, chunkNumber: Int, body: Data, progress: @escaping (Double) -> Void) async throws {
        try releaseUploadChunkResults.removeFirst().get()
    }
    
    func finishReleaseUpload(for releaseUpload: AppCenterAPI.NewReleaseUploadCreated) async throws {
        try finishReleaseUploadResults.removeFirst().get()
    }
    
    func updateReleaseUploadStatus(_ parameters: AppCenterAPI.UpdateReleaseStatusParameters) async throws -> AppCenterAPI.UpdateReleaseStatusResponse {
        try updateReleaseUploadStatusResults.removeFirst().get()
    }
    
    func getUploadRelease(_ parameters: AppCenterAPI.GetUploadReleaseParameters) async throws -> AppCenterAPI.GetUploadReleaseResponse {
        try getUploadReleaseResults.removeFirst().get()
    }
    
    func patchRelease(_ parameters: AppCenterAPI.PatchReleaseParameters) async throws -> AppCenterAPI.PatchReleaseResponse {
        try patchReleaseResults.removeFirst().get()
    }
    
    func beginSymbolsUpload(_ parameters: AppCenterAPI.BeginSymbolsUploadParameters) async throws -> AppCenterAPI.BeginSymbolsUploadResponse {
        try beginSymbolsUploadResults.removeFirst().get()
    }
    
    func symbolsUpload(file: URL, uploadUrl: URL, progress: @escaping (Double) -> Void) async throws {
        
    }
    
    func finishSymbolsUpload(_ parameters: AppCenterAPI.FinishSymbolsUploadParameters) async throws -> AppCenterAPI.FinishSymbolsUploadResponse {
        try finishSymbolsUploadResults.removeFirst().get()
    }
}
