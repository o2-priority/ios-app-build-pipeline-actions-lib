import Foundation
import PathKit

@testable import iOSAppBuildPipelineActionsLib

final class MockAppConfigurationBuilder: AppConfigurationBuilder {
    
    var appConfigurationResults: [AppConfiguration] = []
    
    func appConfiguration(flavour: AppFlavour, distributionMethod: XcodeBuildExportMethod, version: String, buildNumber: Int) throws -> AppConfiguration {
        appConfigurationResults.removeFirst()
    }
}

final class MockAppConfiguration: AppConfiguration {
    
    let appAppleId: String
    let appCenterAppName: String
    let appCenterDistributionGroups: [String]
    let bundleId: String
    let configuration: String
    let exportOptions: XcodeBuildExportOptions
    let provisioningProfile: String
    let scheme: String
    
    init(appAppleId: String,
         appCenterAppName: String,
         appCenterDistributionGroups: [String],
         bundleId: String,
         configuration: String,
         exportOptions: XcodeBuildExportOptions,
         provisioningProfile: String,
         scheme: String)
    {
        self.appAppleId = appAppleId
        self.appCenterAppName = appCenterAppName
        self.appCenterDistributionGroups = appCenterDistributionGroups
        self.bundleId = bundleId
        self.configuration = configuration
        self.exportOptions = exportOptions
        self.provisioningProfile = provisioningProfile
        self.scheme = scheme
    }
    
    var archivePathResults: [Path] = []
    var exportOptionsPlistPathResults: [Path] = []
    var exportPathResults: [Path] = []
    
    func archivePath(baseDir: Path) -> Path {
        archivePathResults.removeFirst()
    }
    
    func exportOptionsPlistPath(baseDir: Path) -> Path {
        exportOptionsPlistPathResults.removeFirst()
    }
    
    func exportPath(baseDir: Path) -> Path {
        exportPathResults.removeFirst()
    }
}
