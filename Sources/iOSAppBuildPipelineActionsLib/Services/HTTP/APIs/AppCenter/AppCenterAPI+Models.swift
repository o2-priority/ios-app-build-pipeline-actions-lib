import Foundation

/**
 Request parameters (path and query)
 */
public extension AppCenterAPI {
    
    struct NewReleaseUploadParameters: Codable {
        let ownerName: String
        let appName: String
    }
    
    struct NewReleaseUploadCreated: Codable {
        let id: String
        let uploadDomain: URL
        let token: String
        let urlEncodedToken: String
        let packageAssetId: String
    }
    
    struct UpdateReleaseStatusParameters: Codable {
        let ownerName: String
        let appName: String
        let uploadId: String
        let body: Body
        
        public struct Body: Codable {
            let uploadStatus: ReleaseStatus
        }
    }
    
    struct GetUploadReleaseParameters: Codable {
        let ownerName: String
        let appName: String
        let uploadId: String
    }
    
    struct PatchReleaseParameters: Codable {
        let ownerName: String
        let appName: String
        let releaseId: String
        let body: Body
        
        public struct Body: Codable {
            struct Build: Codable {
                let branchName: String
                let commitHash: String
                let commitMessage: String
            }
            struct DistributionGroup: Codable {
                let name: String
            }
//            let build: Build
            let destinations: [DistributionGroup]
            let mandatoryUpdate: Bool
            let notifyTesters: Bool
            let releaseNotes: String
        }
    }
    
    struct GetReleaseParameters: Codable {
        let ownerName: String
        let appName: String
        let releaseId: String
    }
    
    struct BeginSymbolsUploadParameters: Codable {
        public struct Body: Codable {
            public enum SymbolType: String, Codable {
                case apple = "Apple"
                case js = "JavaScript"
                case breakpad = "Breakpad"
                case android = "AndroidProguard"
                case uwp = "UWP"
            }
            let symbolType: SymbolType
            let fileName: String
        }
        let ownerName: String
        let appName: String
        let body: Body
    }
    
    struct FinishSymbolsUploadParameters: Codable {
        public struct Body: Codable {
            public enum Status: String, Codable {
                case aborted
                case committed
            }
            let status: Status
        }
        let ownerName: String
        let appName: String
        let symbolUploadId: String
        let body: Body
    }
}

/**
 Response models
 */
public extension AppCenterAPI {
    
    struct SetReleaseUploadMetadataResponse: Codable {
        let id: String
        let blobPartitions: Int
        let chunkSize: Int
        let chunkList: [Int]
        let error: Bool
        let resumeRestart: Bool
        let statusCode: String
    }
    
    struct UpdateReleaseStatusResponse: Codable {
        let id: String
        let uploadStatus: ReleaseStatus
    }
    
    enum ReleaseStatus: String, Codable {
        case uploadStarted, uploadFinished, uploadCanceled, readyToBePublished, malwareDetected, error
    }
    
    struct GetUploadReleaseResponse: Codable {
        let id: String
        let uploadStatus: ReleaseStatus
        let errorDetails: String?
        let releaseDistinctId: Int?
        let releaseUrl: URL?
    }
    
    struct PatchReleaseResponse: Codable {
        let releaseNotes: String
    }
    
    struct BeginSymbolsUploadResponse: Codable {
        let symbolUploadId: String
        let uploadUrl: URL
    }
    
    struct FinishSymbolsUploadResponse: Codable {
        public enum Status: String, Codable {
            case created, committed, aborted, processing, indexed, failed
        }
        let status: Status
    }
}
