import Foundation
import ZIPFoundation

public protocol FileManagerServiceProtocol {
    
    var temporaryDirectory: URL { get }
    
    func fileHandle(forReadingFrom: URL) throws -> FileHandleProtocol
    func removeItem(at URL: URL) throws
    func sizeOfFile(atPath: String) throws -> Int64
    func zipItem(at: URL, to: URL, shouldKeepParent: Bool, compressionMethod: CompressionMethod, progress: Progress?) throws
}

public protocol FileHandleProtocol {
    
    func read(upToCount count: Int) throws -> Data?
}
extension FileHandle: FileHandleProtocol {}

public final class FileManagerService: FileManagerServiceProtocol {
    
    private let fileManager = FileManager.default
    
    public var temporaryDirectory: URL { fileManager.temporaryDirectory }
    
    public init() {}
    
    public func fileHandle(forReadingFrom url: URL) throws -> FileHandleProtocol {
        try FileHandle(forReadingFrom: url)
    }
    
    public func removeItem(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }
    
    public func sizeOfFile(atPath path: String) throws -> Int64 {
        try fileManager.attributesOfItem(atPath: path)[.size] as! Int64
    }
    
    public func zipItem(at sourceURL: URL, to destinationURL: URL, shouldKeepParent: Bool = true, compressionMethod: CompressionMethod = .none, progress: Progress? = nil) throws {
        try fileManager.zipItem(at: sourceURL, to: destinationURL, shouldKeepParent: shouldKeepParent, compressionMethod: compressionMethod, progress: progress)
    }
}
