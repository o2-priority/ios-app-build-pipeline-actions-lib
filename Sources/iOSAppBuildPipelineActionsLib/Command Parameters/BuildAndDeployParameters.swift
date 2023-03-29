import Foundation
import PathKit

public struct BuildAndDeployParameters {
    
    let schemeLocation: XcodeService.SchemeLocation
    let target: String
    let bundleDisplayName: String
    let exportMethod: XcodeBuildExportMethod
    let thinning: XcodeBuildExportOptions.Thinning
    let appFlavours: [AppFlavour]
    let appStoreReleaseConfiguration: String
    let appConfigurationBuilder: AppConfigurationBuilder
    let buildOutputDir: Path
    let buildJobInfo: String?
    let gitHubOwner: String
    let gitHubRepo: String
    let skipDeploy: Bool
    let skipJira: Bool
    let skipSlack: Bool
    
    public init(schemeLocation: XcodeService.SchemeLocation,
                target: String,
                bundleDisplayName: String,
                exportMethod: XcodeBuildExportMethod,
                thinning: XcodeBuildExportOptions.Thinning = .none,
                appFlavours: [AppFlavour],
                appStoreReleaseConfiguration: String,
                appConfigurationBuilder: AppConfigurationBuilder,
                buildOutputDir: Path,
                buildJobInfo: String? = nil,
                gitHubOwner: String,
                gitHubRepo: String,
                skipDeploy: Bool = false,
                skipJira: Bool = false,
                skipSlack: Bool = false)
    {
        self.schemeLocation = schemeLocation
        self.target = target
        self.bundleDisplayName = bundleDisplayName
        self.exportMethod = exportMethod
        self.thinning = thinning
        self.appFlavours = appFlavours
        self.appStoreReleaseConfiguration = appStoreReleaseConfiguration
        self.appConfigurationBuilder = appConfigurationBuilder
        self.buildOutputDir = buildOutputDir
        self.buildJobInfo = buildJobInfo
        self.gitHubOwner = gitHubOwner
        self.gitHubRepo = gitHubRepo
        self.skipDeploy = skipDeploy
        self.skipJira = skipJira || exportMethod == .development
        self.skipSlack = skipSlack
    }
}
