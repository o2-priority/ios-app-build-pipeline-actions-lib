import Foundation
import SwiftUI

public protocol CommandServiceProtocol {
    
    func run<T>(
        _ command: String,
        currentDirectory: URL?,
        textOutputStream: inout T)
    throws -> String where T : TextOutputStream
    
    func run<T>(
        _ command: String,
        currentDirectory: URL?,
        textOutputStream: inout T)
    throws -> Data where T : TextOutputStream
    
    func run<T>(
        _ command: String,
        currentDirectory: URL?,
        textOutputStream: inout T,
        pipeStdErrSeparately: Bool)
    throws -> (Data, Data) where T : TextOutputStream
    
    func run<T>(
        _ command: String,
        currentDirectory: URL?,
        textOutputStream: inout T)
    async throws where T : TextOutputStream
}

public extension CommandServiceProtocol {
    
    func run<T>(
        _ command: String,
        textOutputStream: inout T)
    throws -> String where T : TextOutputStream
    {
        try run(command, currentDirectory: nil, textOutputStream: &textOutputStream)
    }
    
    func run<T>(
        _ command: String,
        textOutputStream: inout T)
    throws -> Data where T : TextOutputStream
    {
        try run(command, currentDirectory: nil, textOutputStream: &textOutputStream)
    }
    
    func run<T>(
        _ command: String,
        textOutputStream: inout T,
        pipeStdErrSeparately: Bool)
    throws -> (Data, Data) where T : TextOutputStream
    {
        try run(command, currentDirectory: nil, textOutputStream: &textOutputStream, pipeStdErrSeparately: pipeStdErrSeparately)
    }
    
    func run<T>(
        _ command: String,
        textOutputStream: inout T)
    async throws where T : TextOutputStream
    {
        try await run(command, currentDirectory: nil, textOutputStream: &textOutputStream)
    }
}

public struct CommandService: CommandServiceProtocol {
    
    public struct Error: Swift.Error, LocalizedError, Equatable {
        
        public let command: String
        public let message: String
        
        init(command: String, message: String) {
            self.command = command
            self.message = message
        }
        
        init(command: String, exitCode: Int32) {
            self.command = command
            self.message = "Exit code \(exitCode)"
        }
        
        public var errorDescription: String? {
            return #""\#(message)" from command "\#(command)""#
        }
    }
    
    public init() {}
    
    @discardableResult
    public func run<T>(_ command: String,
                       currentDirectory: URL?,
                       textOutputStream: inout T)
    throws -> String where T : TextOutputStream
    {
        guard let output = String(data: try run(command, currentDirectory: currentDirectory, textOutputStream: &textOutputStream), encoding: .utf8) else {
            throw Error(command: command, message: "No output")
        }
        return output
    }
    
    public func run<T>(_ command: String,
                       currentDirectory: URL?,
                       textOutputStream: inout T)
    throws -> Data where T : TextOutputStream
    {
        try run(command, currentDirectory: currentDirectory, textOutputStream: &textOutputStream, pipeStdErrSeparately: false).0
    }
    
    public func run<T>(_ command: String,
                       currentDirectory: URL?,
                       textOutputStream: inout T,
                       pipeStdErrSeparately: Bool)
    throws -> (Data, Data) where T : TextOutputStream
    {
        print(command, to: &textOutputStream)
        guard !command.isEmpty else {
            throw Error(command: "", message: "Empty command")
        }
        do {
            let task = Process()
            let pipeStd = Pipe()
            let pipeErr = Pipe()
            task.currentDirectoryURL = currentDirectory
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.arguments = ["-c", command]
            task.standardOutput = pipeStd
            task.standardError = pipeStdErrSeparately ? pipeErr : pipeStd
            try task.run()
            let stdOut = pipeStd.fileHandleForReading.readDataToEndOfFile()
            let stdErr: Data
            if pipeStdErrSeparately {
                stdErr = pipeErr.fileHandleForReading.readDataToEndOfFile()
            } else {
                stdErr = Data()
            }
            task.waitUntilExit()
            guard task.terminationStatus == 0 else {
                throw Error(command: command, exitCode: task.terminationStatus)
            }
            return (stdOut, stdErr)
        } catch let error as Error {
            throw error
        } catch {
            throw Error(command: command, message: error.localizedDescription)
        }
    }
    
    public func run<T>(_ command: String,
                       currentDirectory: URL?,
                       textOutputStream: inout T)
    async throws where T : TextOutputStream
    {
        print(command, to: &textOutputStream)
        guard !command.isEmpty else {
            throw Error(command: "", message: "Empty command")
        }
        do {
            let task = Process()
            let pipe = Pipe()
            task.currentDirectoryURL = currentDirectory
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.arguments = ["-c", command]
            task.standardOutput = pipe
            task.standardError = pipe
            try task.run()
            for try await line in pipe.fileHandleForReading.bytes.lines {
                print(line, to: &textOutputStream)
            }
            task.waitUntilExit()
            guard task.terminationStatus == 0 else {
                throw Error(command: command, exitCode: task.terminationStatus)
            }
        } catch let error as Error {
            throw error
        } catch {
            throw Error(command: command, message: error.localizedDescription)
        }
    }
}
