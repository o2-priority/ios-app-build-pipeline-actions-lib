import Foundation
import PathKit

public protocol AppConfiguration: AppConfigurationAppCenter {
    
    var appAppleId: String { get }
    var bundleId: String { get }
    var configuration: String { get }
    var exportOptions: XcodeBuildExportOptions { get }
    var provisioningProfile: String { get }
    var scheme: String { get }
    
    func archivePath(baseDir: Path) -> Path
    func exportOptionsPlistPath(baseDir: Path) -> Path
    func exportPath(baseDir: Path) -> Path
}

public protocol AppConfigurationAppCenter {
    
    var appCenterAppName: String { get }
    var appCenterDistributionGroups: [String] { get }
}

public protocol AppConfigurationBuilder {
    
    func appConfiguration(flavour: AppFlavour, distributionMethod: XcodeBuildExportMethod, version: String, buildNumber: Int) throws -> AppConfiguration
}
