import Foundation
import PathKit

@testable import iOSAppBuildPipelineActionsLib

final class MockXcodeService: XcodeServiceProtocol {
    
    func getSimulatorIds<T>(simulatorRuntimes: [XcodeService.SimulatorRuntime], preferredSimulatorNames: [String], textOutputStream: inout T) throws -> [XcodeService.SimulatorInfo] where T : TextOutputStream {
        return []
    }
    
    func getAppVersion(xcodeProjPath: Path, target: String, configuration: String) throws -> String {
        ""
    }
    
    func getBuildNumber(xcodeProjPath: Path, target: String, configuration: String) throws -> Int {
        0
    }
    
    func setBuildNumber(_: Int, xcodeProjPath: Path, target: String) throws {
        
    }
    
    func test<T>(schemeLocation: XcodeService.SchemeLocation, scheme: String, destination: String, simulatorRuntime: String, codeCoverageTarget: String?, reportOutputDir: URL, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
    
    func build<T>(schemeLocation: XcodeService.SchemeLocation, scheme: String, destination: String, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
    
    func archive<T>(schemeLocation: XcodeService.SchemeLocation, scheme: String, destination: String, sdk: String, archivePath: Path, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
    
    func writeExportOptionsPlist(_ exportOptions: XcodeBuildExportOptions, exportOptionsPlist: Path) throws {
        
    }
    
    func exportArchive<T>(archivePath: Path, exportPath: Path, exportOptionsPlist: Path, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
    
    func uploadPackage<T>(ipaPath: Path, appAppleId: String, bundleVersion: String, bundleShortVersion: String, bundleId: String, auth: XcodeService.ApplicationLoaderAuth, textOutputStream: inout T) async throws where T : TextOutputStream {
        
    }
}
