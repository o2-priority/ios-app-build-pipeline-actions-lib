import Foundation
import XcodeProj
import PathKit
import ArgumentParser

public protocol XcodeServiceProtocol {
    func getSimulatorIds<T>(
        simulatorRuntimes: [XcodeService.SimulatorRuntime],
        preferredSimulatorNames: [String],
        textOutputStream: inout T,
        verbose: Bool)
    throws -> [XcodeService.SimulatorInfo] where T : TextOutputStream
    func getAppVersion(xcodeProjPath: Path, target: String, configuration: String) throws -> String
    func getBuildNumber(xcodeProjPath: Path, target: String, configuration: String) throws -> Int
    func setBuildNumber(_: Int, xcodeProjPath: Path, target: String) throws
    func test<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        simulatorRuntime: String,
        codeCoverageTarget: String?,
        reportOutputDir: URL,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    func build<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    func archive<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        sdk: String,
        archivePath: Path,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    func writeExportOptionsPlist(_ exportOptions: XcodeBuildExportOptions, exportOptionsPlist: Path) throws
    func exportArchive<T>(
        archivePath: Path,
        exportPath: Path,
        exportOptionsPlist: Path,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    func uploadPackage<T>(
        ipaPath: Path,
        appAppleId: String,
        bundleVersion: String,
        bundleShortVersion: String,
        bundleId: String,
        auth: XcodeService.ApplicationLoaderAuth,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
}

/**
 Resources used for implementation:
 Technical Note TN2339
 Building from the Command Line with Xcode FAQ
 https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-HOW_DO_I_BUILD_MY_PROJECTS_FROM_THE_COMMAND_LINE_
 */
public final class XcodeService: XcodeServiceProtocol {
    
    enum Error: Swift.Error, LocalizedError {
        case noSimulatorsForRuntime(String)
        case unsupportedPlatform(String)
        case unsupportedVersion(String)
        case xcodebuildPathIsNotADirectory(Path)
        case xcbeautifyPathIsNotADirectory(Path)
        
        var errorDescription: String? {
            switch self {
            case let .noSimulatorsForRuntime(devicesKey):
                return "No simulators found under devices key '\(devicesKey)'."
            case let .unsupportedPlatform(platform):
                return "Unsupported platform '\(platform)'."
            case let .unsupportedVersion(version):
                return "Unsupported version '\(version)'."
            case let .xcodebuildPathIsNotADirectory(path):
                return "xcodebuild path is not a directory '\(path.string)'"
            case let .xcbeautifyPathIsNotADirectory(path):
                return "xcbeautify path is not a directory '\(path.string)'"
            }
        }
    }
    
    public typealias SimulatorRuntime = String
    
    let zsh: CommandServiceProtocol
    let xcodebuildPath: Path
    let xcbeautifyPath: Path
    let xchtmlreportPath: Path?
    
    public init(commandService: CommandServiceProtocol,
                xcodebuildPath: Path,
                xcbeautifyPath: Path,
                xchtmlreportPath: Path? = nil) throws
    {
        zsh = commandService
        guard xcodebuildPath.isDirectory else {
            throw Error.xcodebuildPathIsNotADirectory(xcodebuildPath)
        }
        guard xcbeautifyPath.isDirectory else {
            throw Error.xcbeautifyPathIsNotADirectory(xcbeautifyPath)
        }
        self.xcodebuildPath = xcodebuildPath + Path("xcodebuild")
        self.xcbeautifyPath = xcbeautifyPath + Path("xcbeautify")
        if let xchtmlreportPath {
            self.xchtmlreportPath = xchtmlreportPath + Path("xchtmlreport")
        } else {
            self.xchtmlreportPath = nil
        }
    }
    
    public func getSimulatorIds<T>(
        simulatorRuntimes: [SimulatorRuntime],
        preferredSimulatorNames: [String],
        textOutputStream: inout T,
        verbose: Bool)
    throws -> [SimulatorInfo] where T : TextOutputStream
    {
        let jsonDecoder = JSONDecoder()
        return try simulatorRuntimes.enumerated().map { (index, simulatorRuntime) in
            print("Searching for \(simulatorRuntime) simulator runtime... [\(index + 1)/\(simulatorRuntimes.count)]", to: &textOutputStream)
            let simulatorRuntimeComponents = simulatorRuntime.components(separatedBy: "-")
            let supportedPlatforms = ["iOS"]
            guard !simulatorRuntimeComponents.isEmpty, supportedPlatforms.contains(simulatorRuntimeComponents[0]) else {
                throw Error.unsupportedPlatform("\(simulatorRuntimeComponents[0]) is not in the list of supported platforms: \(supportedPlatforms.joined(separator: ", ")).")
            }
            guard !simulatorRuntimeComponents.dropFirst().compactMap(Int.init).isEmpty else {
                throw Error.unsupportedVersion("Non-integer version '\(simulatorRuntimeComponents.dropFirst().joined(separator: "-"))' is not supported.")
            }
            print("Getting list of simulators as JSON...", to: &textOutputStream)
            let (xcrun_simctl_list_json, _) = try self.zsh.run("xcrun simctl list --json", textOutputStream: &textOutputStream, pipeStdErrSeparately: true)
            print("Decoding JSON...", to: &textOutputStream)
            let xcrun_simctl_list = try jsonDecoder.decode(XcrunSimctlList.self, from: xcrun_simctl_list_json)
            if verbose {
                dump(xcrun_simctl_list, to: &textOutputStream)
            }
            let devicesKey = "com.apple.CoreSimulator.SimRuntime.\(simulatorRuntime)"
            print("Searching for devices under '\(devicesKey)'...", to: &textOutputStream)
            guard let devices = xcrun_simctl_list.devices[devicesKey], let firstDevice = devices.first else {
                throw Error.noSimulatorsForRuntime(devicesKey)
            }
            let devicesByName = Dictionary(uniqueKeysWithValues: zip(devices.map { $0.name }, devices))
            print("Searching for devices with preferred name(s)...", to: &textOutputStream)
            for preferredSimulatorName in preferredSimulatorNames {
                if let device = devicesByName[preferredSimulatorName] {
                    print("'\(preferredSimulatorName)' found for \(simulatorRuntime).", to: &textOutputStream)
                    return .init(udid: device.udid, simulatorRuntime: simulatorRuntime)
                } else {
                    print("'\(preferredSimulatorName)' not found for \(simulatorRuntime).", to: &textOutputStream)
                }
            }
            print("No preferred simulator names found, using first device found '\(firstDevice.name)' for \(simulatorRuntime).", to: &textOutputStream)
            return .init(udid: firstDevice.udid, simulatorRuntime: simulatorRuntime)
        }
    }
    
    public func getAppVersion(xcodeProjPath: Path, target: String, configuration: String) throws -> String {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)
        guard let target = xcodeproj.pbxproj.nativeTargets
            .first(where: { $0.name == target })
        else {
            throw ReleaseError.targetNotFound
        }
        guard let buildConfiguration = target.buildConfigurationList?.configuration(name: configuration)
        else {
            throw ReleaseError.buildConfigurationNotFound
        }
        guard let appVersion = buildConfiguration.buildSettings["MARKETING_VERSION"] as? String else {
            throw ReleaseError.appVersionNotFound
        }
        return appVersion
    }
    
    public func getBuildNumber(xcodeProjPath: Path, target: String, configuration: String) throws -> Int {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)
        guard let target = xcodeproj.pbxproj.nativeTargets
            .first(where: { $0.name == target })
        else {
            throw ReleaseError.targetNotFound
        }
        guard let buildConfiguration = target.buildConfigurationList?.configuration(name: configuration)
        else {
            throw ReleaseError.buildConfigurationNotFound
        }
        guard let buildNumberString = buildConfiguration.buildSettings["CURRENT_PROJECT_VERSION"] as? String else {
            throw ReleaseError.buildNumberNotFound
        }
        guard let buildNumber = Int(buildNumberString) else {
            print(buildNumberString)
            throw ReleaseError.buildNumberNotInt
        }
        return buildNumber
    }
    
    public func setBuildNumber(_ buildNumber: Int, xcodeProjPath: Path, target: String) throws {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)
        guard let target = xcodeproj.pbxproj.nativeTargets
            .first(where: { $0.name == target })
        else {
            throw ReleaseError.targetNotFound
        }
        try target.buildConfigurationList?.buildConfigurations.forEach { buildConfiguration in
            buildConfiguration.buildSettings["CURRENT_PROJECT_VERSION"] = buildNumber
            try xcodeproj.write(path: xcodeProjPath)
        }
    }
    
    public func test<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        simulatorRuntime: String,
        codeCoverageTarget: String?,
        reportOutputDir: URL,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    {
        let resultBundlePath = reportOutputDir.appendingPathComponent("\(scheme)-\(simulatorRuntime)-TestResults").path
        let xcodebuildTestCommand = try XcodebuildCommandBuilder()
            .action("test", value: schemeLocation.xcodeBuildArgument)
            .argument("scheme", value: scheme)
            .argument("destination", value: destination)
            .argument("resultBundlePath", value: resultBundlePath)
            .build(xcodebuildPath: xcodebuildPath, xcbeautifyPath: xcbeautifyPath)
        try await zsh.run(xcodebuildTestCommand, textOutputStream: &textOutputStream)
        if let xchtmlreportPath {
            try await zsh.run("\(xchtmlreportPath.string) -r \(resultBundlePath)", textOutputStream: &textOutputStream)
        }
        guard let codeCoverageTarget else {
            print("No code coverage target specified.", to: &textOutputStream)
            return
        }
        let codeCovOutput: String = try zsh.run("xcrun xccov view --report --only-targets --json \(resultBundlePath).xcresult", textOutputStream: &textOutputStream)
        let codeCoverageReport = codeCovOutput
            .components(separatedBy: "\n")
            .compactMap { $0.data(using: .utf8) }
            .compactMap { data in
                try? JSONDecoder().decode([XccovViewReportOnlyTargetsItem].self, from: data)
            }
            .flatMap { $0 }
        // Output CodeCoveragePercentage.json
        if let codeCoverage = codeCoverageReport.filter({ item in
            item.name == codeCoverageTarget
        }).first.map({ item in
            CodeCoverage(lineRate: item.lineCoverage)
        }) {
            try JSONEncoder().encode(codeCoverage).write(to: reportOutputDir.appendingPathComponent("CodeCoveragePercentage.json"))
        } else {
            print("No code coverage found for \(codeCoverageTarget)", to: &textOutputStream)
        }
        // Generate code coverage in cobertura XML format
        try await zsh.run("xcrun xccov view --report --json \(resultBundlePath).xcresult > coverage.json", currentDirectory: reportOutputDir, textOutputStream: &textOutputStream)
        try await zsh.run("xcc generate coverage.json CodeCoverageXML cobertura-xml", currentDirectory: reportOutputDir, textOutputStream: &textOutputStream)
    }
    
    public func build<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    {
        let xcodebuildCommand = try XcodebuildCommandBuilder()
            .action("build", value: schemeLocation.xcodeBuildArgument)
            .argument("scheme", value: scheme)
            .argument("destination", value: destination)
            .build(xcodebuildPath: xcodebuildPath, xcbeautifyPath: xcbeautifyPath)
        try await zsh.run(xcodebuildCommand, textOutputStream: &textOutputStream)
    }
    
    public func archive<T>(
        schemeLocation: XcodeService.SchemeLocation,
        scheme: String,
        destination: String,
        sdk: String,
        archivePath: Path,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    {
        let xcodebuildArchiveCommand = try XcodebuildCommandBuilder()
            .action("archive", value: schemeLocation.xcodeBuildArgument)
            .argument("scheme", value: scheme)
            .argument("destination", value: destination)
            .argument("sdk", value: sdk)
            .argument("archivePath", value: archivePath.string)
            .build(xcodebuildPath: xcodebuildPath, xcbeautifyPath: xcbeautifyPath)
        try await zsh.run(xcodebuildArchiveCommand, textOutputStream: &textOutputStream)
    }
    
    public func writeExportOptionsPlist(_ exportOptions: XcodeBuildExportOptions, exportOptionsPlist: Path) throws {
        try PropertyListEncoder()
            .encode(exportOptions)
            .write(to: exportOptionsPlist.url)
    }
    
    public func exportArchive<T>(
        archivePath: Path,
        exportPath: Path,
        exportOptionsPlist: Path,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    {
        let xcodebuildExportArchiveCommand = try XcodebuildCommandBuilder()
            .flag("exportArchive")
            .argument("archivePath", value: archivePath.string)
            .argument("exportPath", value: exportPath.string)
            .argument("exportOptionsPlist", value: exportOptionsPlist.string)
            .build(xcodebuildPath: xcodebuildPath, xcbeautifyPath: xcbeautifyPath)
        try await zsh.run(xcodebuildExportArchiveCommand, textOutputStream: &textOutputStream)
    }
    
    public func uploadPackage<T>(
        ipaPath: Path,
        appAppleId: String,
        bundleVersion: String,
        bundleShortVersion: String,
        bundleId: String,
        auth: XcodeService.ApplicationLoaderAuth,
        textOutputStream: inout T
    ) async throws where T : TextOutputStream
    {
        print("Uploading ipa using Application Loader...", to: &textOutputStream)
        try await zsh.run("xcrun altool --upload-package \(ipaPath) --type ios --apple-id \(appAppleId) --bundle-version \(bundleVersion) --bundle-short-version-string \(bundleShortVersion) --bundle-id \(bundleId) \(auth.command)", textOutputStream: &textOutputStream)
    }
    
    // MARK: Supporting Types
    
    public struct SimulatorInfo: Equatable {
        let udid: UUID
        let simulatorRuntime: String
    }
    
    public enum SchemeLocation: ExpressibleByArgument {
        
        case project(Path)
        case workspace(Path)
        
        public init?(argument: String) {
            if argument.hasSuffix(".xcworkspace") {
                self = .workspace(Path(argument))
            } else if argument.hasSuffix(".xcodeproj") {
                self = .project(Path(argument))
            } else {
                return nil
            }
        }
        
        var path: Path {
            switch self {
            case .project(let path), .workspace(let path):
                return path
            }
        }
        
        var xcodeBuildArgument: String {
            switch self {
            case .project(let project):
                return "-project \(project.string)"
            case .workspace(let workspace):
                return "-workspace \(workspace.string)"
            }
        }
    }
    
    public enum ApplicationLoaderAuth {
        public struct Basic {
            let username: String
            let password: String
        }
        public struct Token {
            let apiKey: String
            let apiIssuer: String
        }
        case basic(Basic)
        case token(Token)
        
        var command: String {
            switch self {
            case .basic(let auth):
                return "-u \(auth.username) -p \(auth.password)"
            case .token(let auth):
                return "--apiKey \(auth.apiKey) --apiIssuer \(auth.apiIssuer)"
            }
        }
    }
    
    struct XccovViewReportOnlyTargetsItem: Codable {
        let lineCoverage: Double
        let name: String
    }
    
    // MARK: xcrun simctl list --json
    struct XcrunSimctlList: Codable {
        typealias SimRuntime = String
        struct SimDevice: Codable {
            let dataPath: String
            let dataPathSize: Int
            let deviceTypeIdentifier: String
            let isAvailable: Bool
            let logPath: String
            let name: String
            let state: String
            let udid: UUID
        }
        let devices: [SimRuntime: [SimDevice]]
    }
    
    struct CodeCoverage: Codable {
        let lineRate: Double
        
        enum CodingKeys: String, CodingKey {
            case lineRate = "line-rate"
        }
    }
    
    final class XcodebuildCommandBuilder {
        
        private var action: String?
        private var options: [String] = []
        
        func action(_ name: String, value: String) -> Self {
            action = "\(name) \(value) "
            return self
        }
        
        func argument(_ name: String, value: String) -> Self {
            options.append("-\(name) \(value)")
            return self
        }
        
        func flag(_ name: String) -> Self {
            options.append("-\(name)")
            return self
        }
        
        func build(xcodebuildPath: Path, xcbeautifyPath: Path) throws -> String {
            "set -o pipefail && " //Required to make xcbeautify return status to equal the last command to exit with a non-zero status, or zero if all commands exit successfully.
                .appending(xcodebuildPath.string)
                .appending(" ")
                .appending(action ?? "")
                .appending(options.joined(separator: " "))
                .appending(" | ")
                .appending(xcbeautifyPath.string)
        }
    }
}
