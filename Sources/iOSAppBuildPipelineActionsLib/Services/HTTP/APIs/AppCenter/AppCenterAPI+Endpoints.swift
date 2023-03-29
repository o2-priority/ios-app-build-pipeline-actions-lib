import Foundation

/**
 https://docs.microsoft.com/en-us/appcenter/distribution/uploading#upload-new-release
 */
public extension AppCenterAPI {
    
    struct NewReleaseUploadRequest: HTTPRequestable {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        
        init(parameters: NewReleaseUploadParameters, accessToken: String) {
            method = "POST"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/uploads/releases"
            headers["X-API-Token"] = accessToken
        }
    }
    
    struct SetReleaseUploadMetadataRequest: HTTPRequestable, AcceptJSON {
        
        struct Metadata: Codable {
            var contentType: String = "application/octet-stream"
            let fileName: String
            let fileSize: Int
            let token: String
        }
        
        public let baseURLString: String?
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        
        init(releaseUpload: NewReleaseUploadCreated, fileName: String, fileSize: Int, accessToken: String) throws {
            baseURLString = releaseUpload.uploadDomain.absoluteString
            method = "POST"
            let metadata = Metadata(fileName: fileName, fileSize: fileSize, token: releaseUpload.token)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            var urlComponents = URLComponents()
            urlComponents.path = "/upload/set_metadata/\(releaseUpload.packageAssetId)"
            urlComponents.queryItems = try metadata.asDictionary(using: jsonEncoder).queryItems
            guard let path = urlComponents.string else { throw ActionsError.malformedInput(description: "") }
            self.path = path
//            self.path = "\(path)&token=\(releaseUpload.urlEncodedToken)"
            headers["X-API-Token"] = accessToken
            addAcceptHeader()
        }
    }
    
    struct ReleaseUploadChunkRequest: HTTPRequestable, ContentTypeOctetStream {
        
        struct Query: Codable {
            let blockNumber: Int
            let token: String
        }
        
        public let baseURLString: String?
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let body: Data
        
        init(releaseUpload: NewReleaseUploadCreated, blockNumber: Int, content: Data) throws {
            baseURLString = releaseUpload.uploadDomain.absoluteString
            method = "POST"
            let query = Query(blockNumber: blockNumber, token: releaseUpload.token)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            var urlComponents = URLComponents()
            urlComponents.path = "/upload/upload_chunk/\(releaseUpload.packageAssetId)"
            urlComponents.queryItems = try query.asDictionary(using: jsonEncoder).queryItems
            guard let path = urlComponents.string else { throw ActionsError.malformedInput(description: "") }
            self.path = path
            self.body = content
            addContentTypeHeader()
            addContentLengthHeader()
        }
    }
    
    struct FinishReleaseUploadRequest: HTTPRequestable, AcceptJSON {
        
        struct Query: Codable {
            let token: String
        }
        
        public let baseURLString: String?
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        
        init(releaseUpload: NewReleaseUploadCreated, accessToken: String) throws {
            baseURLString = releaseUpload.uploadDomain.absoluteString
            method = "POST"
            let query = Query(token: releaseUpload.token)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            var urlComponents = URLComponents()
            urlComponents.path = "/upload/finished/\(releaseUpload.packageAssetId)"
            urlComponents.queryItems = try query.asDictionary(using: jsonEncoder).queryItems
            guard let path = urlComponents.string else { throw ActionsError.malformedInput(description: "") }
            self.path = path
            headers["X-API-Token"] = accessToken
            addAcceptHeader()
        }
    }
    
    struct UpdateReleaseStatusRequest: HTTPRequestable, ContentTypeJSON {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let content: UpdateReleaseStatusParameters.Body
        public let jsonEncoder = JSONEncoder()
        
        init(parameters: UpdateReleaseStatusParameters, accessToken: String) {
            method = "PATCH"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/uploads/releases/\(parameters.uploadId)"
            headers["X-API-Token"] = accessToken
            content = parameters.body
            addContentTypeHeader()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        }
    }
    
    struct GetUploadReleaseRequest: HTTPRequestable {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        
        init(parameters: GetUploadReleaseParameters, accessToken: String) {
            method = "GET"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/uploads/releases/\(parameters.uploadId)"
            headers["X-API-Token"] = accessToken
        }
    }
    
    struct PatchReleaseRequest: HTTPRequestable, ContentTypeJSON, AcceptJSON {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let content: PatchReleaseParameters.Body
        public let jsonEncoder = JSONEncoder()
        
        init(parameters: PatchReleaseParameters, accessToken: String) {
            method = "PATCH"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/releases/\(parameters.releaseId)"
            headers["X-API-Token"] = accessToken
            content = parameters.body
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            addContentTypeHeader()
            addAcceptHeader()
        }
    }
    
    struct GetReleaseRequest: HTTPRequestable {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        
        init(parameters: GetReleaseParameters, accessToken: String) {
            method = "GET"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/releases/\(parameters.releaseId)"
            headers["X-API-Token"] = accessToken
        }
    }
    
    struct BeginSymbolsUploadRequest: HTTPRequestable, ContentTypeJSON, AcceptJSON {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let content: BeginSymbolsUploadParameters.Body
        public let jsonEncoder = JSONEncoder()
        
        init(parameters: BeginSymbolsUploadParameters, accessToken: String) {
            method = "POST"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/symbol_uploads"
            headers["X-API-Token"] = accessToken
            content = parameters.body
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            addContentTypeHeader()
            addAcceptHeader()
        }
    }
    
    struct SymbolsUploadRequest: HTTPRequestable {
        
        public let baseURLString: String?
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let body = Data()
        
        init(uploadUrl: URL) throws {
            baseURLString = uploadUrl.absoluteString
            method = "PUT"
            path = ""
            headers["x-ms-blob-type"] = "BlockBlob"
        }
    }
    
    struct FinishSymbolsUploadRequest: HTTPRequestable, ContentTypeJSON, AcceptJSON {
        
        public let method: String
        public let path: String
        public var headers: [String : String] = [:]
        public let content: FinishSymbolsUploadParameters.Body
        public let jsonEncoder = JSONEncoder()
        
        init(parameters: FinishSymbolsUploadParameters, accessToken: String) {
            method = "PATCH"
            path = "/v0.1/apps/\(parameters.ownerName)/\(parameters.appName)/symbol_uploads/\(parameters.symbolUploadId)"
            headers["X-API-Token"] = accessToken
            content = parameters.body
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            addContentTypeHeader()
            addAcceptHeader()
        }
    }
}
