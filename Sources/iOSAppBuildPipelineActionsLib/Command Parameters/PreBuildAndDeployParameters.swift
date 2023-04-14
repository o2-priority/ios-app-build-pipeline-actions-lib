import Foundation
import PathKit

public struct PreBuildAndDeployParameters {
    
    public enum BuildNumberOption {
        case fetch(id: String)
        case local(Int)
    }
    
    let schemeLocation: XcodeService.SchemeLocation
    let target: String
    let exportMethod: XcodeBuildExportMethod
    let appFlavours: [AppFlavour]
    let simulatorRuntimes: [String]
    let preferredSimulatorNames: [String]
    let schemeForTest: String
    let appStoreReleaseConfiguration: String
    let buildNumberOption: BuildNumberOption
    let appConfigurationBuilder: AppConfigurationBuilder
    let buildOutputDir: Path
    let buildJobInfo: String?
    let gitHubOwner: String
    let gitHubRepo: String
    let skipTest: Bool
    
    public init(schemeLocation: XcodeService.SchemeLocation,
                target: String,
                exportMethod: XcodeBuildExportMethod,
                appFlavours: [AppFlavour],
                simulatorRuntimes: [String],
                preferredSimulatorNames: [String],
                schemeForTest: String,
                appStoreReleaseConfiguration: String,
                buildNumberOption: BuildNumberOption,
                appConfigurationBuilder: AppConfigurationBuilder,
                buildOutputDir: Path,
                buildJobInfo: String? = nil,
                gitHubOwner: String,
                gitHubRepo: String,
                skipTest: Bool = false)
    {
        self.schemeLocation = schemeLocation
        self.target = target
        self.exportMethod = exportMethod
        self.appFlavours = appFlavours
        self.simulatorRuntimes = simulatorRuntimes
        self.preferredSimulatorNames = preferredSimulatorNames
        self.schemeForTest = schemeForTest
        self.appStoreReleaseConfiguration = appStoreReleaseConfiguration
        self.buildNumberOption = buildNumberOption
        self.appConfigurationBuilder = appConfigurationBuilder
        self.buildOutputDir = buildOutputDir
        self.buildJobInfo = buildJobInfo
        self.gitHubOwner = gitHubOwner
        self.gitHubRepo = gitHubRepo
        self.skipTest = skipTest
    }
    
    public func buildAndDeployParameters(bundleDisplayName: String,
                                         thinning: XcodeBuildExportOptions.Thinning,
                                         skipDeploy: Bool,
                                         skipJira: Bool,
                                         skipSlack: Bool) -> BuildAndDeployParameters
    {
        .init(
            schemeLocation: schemeLocation,
            target: target,
            bundleDisplayName: bundleDisplayName,
            exportMethod: exportMethod,
            thinning: thinning,
            appFlavours: appFlavours,
            appStoreReleaseConfiguration: appStoreReleaseConfiguration,
            appConfigurationBuilder: appConfigurationBuilder,
            buildOutputDir: buildOutputDir,
            buildJobInfo: buildJobInfo,
            gitHubOwner: gitHubOwner,
            gitHubRepo: gitHubRepo,
            skipDeploy: skipDeploy,
            skipJira: skipJira,
            skipSlack: skipSlack)
    }
}
