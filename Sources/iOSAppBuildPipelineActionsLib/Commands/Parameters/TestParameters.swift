import Foundation
import PathKit

public struct TestParameters {
    
    let schemeLocation: XcodeService.SchemeLocation
    let scheme: String
    let simulatorRuntimes: [String]
    let preferredSimulatorNames: [String]
    let codeCoverageTarget: String
    let reportOutputDir: Path
    
    public init(schemeLocation: XcodeService.SchemeLocation,
         scheme: String,
         simulatorRuntimes: [String],
         preferredSimulatorNames: [String],
         codeCoverageTarget: String,
         reportOutputDir: Path) throws
    {
        self.schemeLocation = schemeLocation
        self.scheme = scheme
        self.simulatorRuntimes = simulatorRuntimes
        self.preferredSimulatorNames = preferredSimulatorNames
        self.codeCoverageTarget = codeCoverageTarget
        self.reportOutputDir = reportOutputDir
    }
}
