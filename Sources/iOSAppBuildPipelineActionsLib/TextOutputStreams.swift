import Foundation

public protocol RedactableTextOutputStream: TextOutputStream {
    func redact(string: String)
}

public final class StandardRedactedOutputStream: RedactableTextOutputStream {
    
    private var redact: [String] = []
    
    public init() {}
    
    public func write(_ string: String) {
        let redacted = redact.reduce(string) { partialResult, redact in
            partialResult.replacingOccurrences(of: redact, with: "[REDACTED]")
        }
        FileHandle.standardOutput.write(Data(redacted.utf8))
    }
    
    public func redact(string: String) {
        redact.append(string)
    }
}

public class StandardErrorStream: TextOutputStream {
    public init() {}
    public func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}
