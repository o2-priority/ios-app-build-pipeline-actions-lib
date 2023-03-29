import Foundation
import ZIPFoundation

@testable import iOSAppBuildPipelineActionsLib

final class MockFileManagerService: FileManagerServiceProtocol {
    
    enum ZipItemProgress {
        case cancelled
        case finished
    }
    
    var zipItemProgressReturnValues: [ZipItemProgress] = [.finished]
    
    var temporaryDirectory: URL {
        .init(fileURLWithPath: "/tmp")
    }
    
    func fileHandle(forReadingFrom: URL) throws -> FileHandleProtocol {
        MockFileHandle()
    }
    
    func removeItem(at URL: URL) throws {
        
    }
    
    func sizeOfFile(atPath: String) throws -> Int64 {
        0
    }
    
    func zipItem(at: URL, to: URL, shouldKeepParent: Bool, compressionMethod: CompressionMethod, progress: Progress?) throws {
        if let progress {
            progress.totalUnitCount = 1
            switch zipItemProgressReturnValues.removeFirst() {
            case .cancelled:
                progress.cancel()
            case .finished:
                progress.completedUnitCount = progress.totalUnitCount
            }
        }
    }
}

final class MockFileHandle: FileHandleProtocol {
    
    func read(upToCount count: Int) throws -> Data? {
        nil
    }
}
