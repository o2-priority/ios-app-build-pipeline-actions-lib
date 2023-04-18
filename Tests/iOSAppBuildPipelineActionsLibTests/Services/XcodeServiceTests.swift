import Foundation
import XCTest

@testable import iOSAppBuildPipelineActionsLib

final class XcodeServiceTests: XCTestCase {
    
    var sut: XcodeService!
    var mockCommandService: MockCommandService!
    var mockTextOutputStream: MockRedactableTextOutputStream!

    override func setUpWithError() throws {
        mockCommandService = MockCommandService()
        mockTextOutputStream = MockRedactableTextOutputStream()
        sut = .init(commandService: mockCommandService)
    }
    
    func test_getSimulatorIds_unsupportedPlatform() throws {
        //Given
        let simulatorRuntimes = ["macOS-16-4"]
        
        //When
        XCTAssertThrowsError(try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream))
        
        //Then
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for macOS-16-4 simulator runtime... [1/1]", "\n"
        ])
    }
    
    func test_getSimulatorIds_unsupportedVersion() throws {
        //Given
        let simulatorRuntimes = ["iOS-A"]
        
        //When
        XCTAssertThrowsError(try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream))
        
        //Then
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-A simulator runtime... [1/1]", "\n"
        ])
    }
    
    func test_getSimulatorIds_noInstalledSimulatorRuntimes() throws {
        //Given
        let xcrun_simctl_list__json = try XCTUnwrap("""
        {
          "devices" : {}
        }
        """.data(using: .utf8))
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-16-4"]
        
        //When
        XCTAssertThrowsError(try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream))
        
        //Then
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-16-4 simulator runtime... [1/1]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n"
        ])
    }
    
    func test_getSimulatorIds_noInstalledSimulatorDevices() throws {
        //Given
        let xcrun_simctl_list__json = try XCTUnwrap("""
        {
          "devices" : {
            "com.apple.CoreSimulator.SimRuntime.iOS-16-4" : []
          }
        }
        """.data(using: .utf8))
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-16-4"]
        
        //When
        XCTAssertThrowsError(try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream))
        
        //Then
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-16-4 simulator runtime... [1/1]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n"
        ])
    }
    
    func test_getSimulatorIds_noMatchingSimulatorRuntimes() throws {
        //Given
        let xcrun_simctl_list__json = try XCTUnwrap("""
        {
          "devices" : {
            "com.apple.CoreSimulator.SimRuntime.iOS-17-0" : [
              {
                "dataPath" : "/Users/user/Library/Developer/CoreSimulator/Devices/A0492998-4FE2-4B60-8D39-46C1F1A1D2D1/data",
                "dataPathSize" : 13316096,
                "logPath" : "/Users/user/Library/Logs/CoreSimulator/A0492998-4FE2-4B60-8D39-46C1F1A1D2D1",
                "udid" : "A0492998-4FE2-4B60-8D39-46C1F1A1D2D1",
                "isAvailable" : true,
                "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
                "state" : "Shutdown",
                "name" : "iPhone 15"
              }
            ]
          }
        }
        """.data(using: .utf8))
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-16-4"]
        
        //When
        XCTAssertThrowsError(try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream))
        
        //Then
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-16-4 simulator runtime... [1/1]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n"
        ])
    }
    
    func test_getSimulatorIds_singleSimulatorRuntime_noPreferredSimulatorName() throws {
        //Given
        let xcrun_simctl_list__json = try getJSONData(from: "Stubs/xcrun-simctl-list")
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-16-4"]
        
        //When
        let simulatorIds = try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream)
        
        //Then
        XCTAssertEqual(simulatorIds, [
            .init(udid: .init(uuidString: "A0492998-4FE2-4B60-8D39-46C1F1A1D2D1")!, simulatorRuntime: "iOS-16-4")
        ])
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-16-4 simulator runtime... [1/1]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n",
            "", "Searching for devices with preferred name(s)...", "\n",
            "", "No preferred simulator names found, using first device found \'iPhone SE (3rd generation)\' for iOS-16-4.", "\n"
        ])
    }

    func test_getSimulatorIds_multipleSimulatorRuntimes_noPreferredSimulatorName() throws {
        //Given
        let xcrun_simctl_list__json = try getJSONData(from: "Stubs/xcrun-simctl-list")
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-15-0", "iOS-16-4"]
        
        //When
        let simulatorIds = try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: [], textOutputStream: &mockTextOutputStream)
        
        //Then
        XCTAssertEqual(simulatorIds, [
            .init(udid: .init(uuidString: "C8075B34-C533-4190-A304-3EB4323433B9")!, simulatorRuntime: "iOS-15-0"),
            .init(udid: .init(uuidString: "A0492998-4FE2-4B60-8D39-46C1F1A1D2D1")!, simulatorRuntime: "iOS-16-4")
        ])
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-15-0 simulator runtime... [1/2]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-15-0\'...", "\n",
            "", "Searching for devices with preferred name(s)...", "\n",
            "", "No preferred simulator names found, using first device found \'iPhone SE (1st generation)\' for iOS-15-0.", "\n",
            "", "Searching for iOS-16-4 simulator runtime... [2/2]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n",
            "", "Searching for devices with preferred name(s)...", "\n",
            "", "No preferred simulator names found, using first device found \'iPhone SE (3rd generation)\' for iOS-16-4.", "\n"
        ])
    }
    
    func test_getSimulatorIds_multipleSimulatorRuntimes_withPreferredSimulatorName() throws {
        //Given
        let xcrun_simctl_list__json = try getJSONData(from: "Stubs/xcrun-simctl-list")
        mockCommandService.resultsData = [
            (xcrun_simctl_list__json, Data()),
            (xcrun_simctl_list__json, Data())
        ]
        let simulatorRuntimes = ["iOS-15-0", "iOS-16-4"]
        let preferredSimulatorNames = ["iPhone 14"]
        
        //When
        let simulatorIds = try sut.getSimulatorIds(simulatorRuntimes: simulatorRuntimes, preferredSimulatorNames: preferredSimulatorNames, textOutputStream: &mockTextOutputStream)
        
        //Then
        XCTAssertEqual(simulatorIds, [
            .init(udid: .init(uuidString: "C8075B34-C533-4190-A304-3EB4323433B9")!, simulatorRuntime: "iOS-15-0"),
            .init(udid: .init(uuidString: "BE99020D-5218-42FC-9F25-690559B6227D")!, simulatorRuntime: "iOS-16-4")
        ])
        XCTAssertEqual(mockTextOutputStream.writes, [
            "", "Searching for iOS-15-0 simulator runtime... [1/2]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-15-0\'...", "\n",
            "", "Searching for devices with preferred name(s)...", "\n",
            "", "\'iPhone 14\' not found for iOS-15-0.", "\n",
            "", "No preferred simulator names found, using first device found \'iPhone SE (1st generation)\' for iOS-15-0.", "\n",
            "", "Searching for iOS-16-4 simulator runtime... [2/2]", "\n",
            "", "Getting list of simulators as JSON...", "\n",
            "", "Decoding JSON...", "\n",
            "", "Searching for devices under \'com.apple.CoreSimulator.SimRuntime.iOS-16-4\'...", "\n",
            "", "Searching for devices with preferred name(s)...", "\n",
            "", "\'iPhone 14\' found for iOS-16-4.", "\n"
        ])
    }
}
