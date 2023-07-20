import Foundation
import PathKit

public protocol GitServiceProtocol {
    
    func add(path: Path) throws
    func commit(subject: String, body: String?) throws
    func fetchCurrentBranch() throws -> Git.Branch
    func fetchAncestryPathGitLog(comparisonTag: String) throws -> String
    func isWorkingDirectoryClean() throws -> Bool
    func push(remote: String, branch: String) throws
}

public final class GitService<T>: GitServiceProtocol where T: RedactableTextOutputStream {
    
    let zsh: CommandServiceProtocol
    let repoDir: Path
    private var textOutputStream: T
    
    public init(commandService: CommandServiceProtocol, repoDir: Path, textOutputStream: T) {
        zsh = commandService
        self.repoDir = repoDir
        self.textOutputStream = textOutputStream
    }
    
    @discardableResult
    public func git(_ command: String) throws -> String {
        try zsh.run(#"git --git-dir="\#(repoDir)/.git" --work-tree=\#(repoDir) \#(command)"#, textOutputStream: &textOutputStream)
    }
    
    public func add(path: Path) throws {
        try git("add \(path.string)")
    }
    
    public func commit(subject: String, body: String?) throws {
        var command = #"commit -a -m "\#(subject)""#
        if let body = body {
            command = command.appending(#" -m "\#(body)""#)
        }
        try git(command)
    }
    
    public func fetchCurrentBranch() throws -> Git.Branch {
        let gitBranch = try git("branch --show-current")
        return Git.Branch(name: gitBranch.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func fetchAncestryPathGitLog(comparisonTag: String) throws -> String {
        let currentBranch = try fetchCurrentBranch()
        try git("fetch origin tag \(comparisonTag)")
        try git("checkout tags/\(comparisonTag)")
        try git("checkout \(currentBranch.name)")
        let commonAncestor = try git("merge-base tags/\(comparisonTag) \(currentBranch.name)").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commonAncestor.isEmpty else {
            throw CommandService.Error(
                command: "git merge-base \(comparisonTag) \(currentBranch.name)",
                message: "No common ancestor found between `\(comparisonTag)` and `\(currentBranch.name)`")
        }
        let ancestryPathGitLog = try git("--no-pager rev-list --ancestry-path \(commonAncestor)..\(currentBranch.name)")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .compactMap { try? git("--no-pager log --oneline \($0) -n 1") }
            .joined()
        return ancestryPathGitLog.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func isWorkingDirectoryClean() throws -> Bool {
        try git("diff HEAD").isEmpty
    }
    
    public func push(remote: String, branch: String) throws {
        try git("push \(remote) \(branch)")
    }
}
