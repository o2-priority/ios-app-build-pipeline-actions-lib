import Foundation
import XCTest
import PathKit

@testable import iOSAppBuildPipelineActionsLib

final class BuildAndDeployTests: XCTestCase {
    
    // SUT
    var actions: BuildAndDeploy<MockRedactableTextOutputStream>!
    
    // SUT Dependencies
    var appCenterAPI: MockAppCenterAPI!
    var atlassianAPI: MockAtlassianAPI!
    var bitriseAPI: MockBitriseAPI!
    var buildNumberAPI: MockBuildNumberAPI!
    var fileManagerService: MockFileManagerService!
    var gitService: MockGitService!
    var gitHubAPI: MockGitHubAPI!
    var processInfoService: MockProcessInfoService!
    var slackAPI: MockSlackAPI!
    var textOutputStream = MockRedactableTextOutputStream()
    var xcodeService: MockXcodeService!
    
    let mock200Response = HTTPURLResponse(url: URL(string: "www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let releaseNotesInput = try! ReleaseNotesParameters(environments: "dev,test",
                                                        distributionMethod: "enterprise",
                                                        confluenceSpaceId: "sid",
                                                        confluenceParentPageId: "pageId",
                                                        pageTitle: "pageTitle1",
                                                        gitHubOwner: "owner",
                                                        gitHubRepo: "repo")
    
    override func setUp() {
        appCenterAPI = MockAppCenterAPI()
        atlassianAPI = MockAtlassianAPI()
        bitriseAPI = MockBitriseAPI()
        buildNumberAPI = MockBuildNumberAPI()
        fileManagerService = MockFileManagerService()
        gitService = MockGitService()
        gitHubAPI = MockGitHubAPI()
        processInfoService = MockProcessInfoService()
        slackAPI = MockSlackAPI()
        xcodeService = MockXcodeService()
        actions = BuildAndDeploy(appCenterAPI: appCenterAPI, atlassianAPI: atlassianAPI, bitriseAPI: bitriseAPI, buildNumberAPI: buildNumberAPI, fileManagerService: fileManagerService, gitHubAPI: gitHubAPI, gitService: gitService, processInfoService: processInfoService, slackAPI: slackAPI, xcodeService: xcodeService, textOutputStream: textOutputStream, isCI: false)
    }
    
    func test_prepareRelease() async throws {
        //Given
        appCenterAPI.beginSymbolsUploadResults = [.success(.init(symbolUploadId: "1", uploadUrl: .init(string: "https://appcenter.ms/upload/1")!))]
        appCenterAPI.finishSymbolsUploadResults = [.success(.init(status: .created))]
        atlassianAPI.commentOnTicketResults = [.success(())]
        atlassianAPI.moveTicketToQAResults = [.success(())]
        buildNumberAPI.getNextBuildNumberResults = [.success(1)]
        gitService.fetchBranchResult = .success(.init(name: "feature/PR-1234/ios"))
        gitService.isWorkingDirectoryCleanResult = .success(true)
        gitHubAPI.pullRequestResults = [.success([])]
        processInfoService.environment = [
            "CONFLUENCE_RELEASE_NOTES_SPACE_ID" : "0",
            "CONFLUENCE_RELEASE_NOTES_PARENT_PAGE_ID" : "1",
            "ALTOOL_USERNAME" : "user",
            "ALTOOL_PASSWORD" : "pass",
            "APPCENTER_OWNER_NAME" : "owner",
            "JIRA_QA_COLUMN_ID" : "1",
            "SLACK_WEBHOOK_URL" : "https://hooks.slack.com/services/a/b/c"
        ]
        let appConfigurationBuilder = MockAppConfigurationBuilder()
        let appConfiguration = MockAppConfiguration(appAppleId: "", appCenterAppName: "Prod", appCenterDistributionGroups: [], bundleId: "", configuration: "Release", exportOptions: .init(compileBitcode: false, destination: .export, generateAppStoreInformation: true, manageAppVersionAndBuildNumber: false, method: .appstore, provisioningProfiles: [:], signingCertificate: .automatic(.appleDistribution), signingStyle: .automatic, stripSwiftSymbols: false, teamID: "", thinning: .none, uploadBitcode: false, uploadSymbols: false), provisioningProfile: "", scheme: "Prod-Release")
        appConfiguration.archivePathResults = [.temporary]
        appConfiguration.exportOptionsPlistPathResults = [.temporary]
        appConfiguration.exportPathResults = [.temporary]
        appConfigurationBuilder.appConfigurationResults = [appConfiguration]
        
        let releaseInput = PreBuildAndDeployParameters(
            schemeLocation: .project(""),
            target: "App",
            exportMethod: .appstore,
            appFlavours: [.init(appBundleIdSuffix: "", baseBundleId: "com.apple", label: "Prod", labelIncludingRelease: "Prod-Release", name: "prod")],
            simulatorRuntimes: ["iOS-15-0", "iOS-16-4"],
            preferredSimulatorNames: ["iPhone 14"],
            schemeForTest: "",
            testPlan: nil,
            appStoreReleaseConfiguration: "",
            buildNumberOption: .local(1),
            appConfigurationBuilder: appConfigurationBuilder,
            buildOutputDir: Path("/"),
            gitHubOwner: "owner",
            gitHubRepo: "repo",
            skipTest: false)
        //When
        try await actions.preBuildAndDeploy(releaseInput, buildAndDeployParameters: releaseInput.buildAndDeployParameters(bundleDisplayName: "", thinning: .none, skipDeploy: true, skipJira: true, skipSlack: true))
        //Then
        XCTAssertEqual(textOutputStream.writes, [
            "", "Bitrise Restore SPM Cache step not detected.", "\n",
            "", "Testing app...", "\n",
            "", "Reading Xcode project app version...", "\n",
            "", "", "\n",
            "", "Setting Xcode project build number to 1", "\n",
            "", "Preparing release notes...", "\n",
            "", "No pull request found.", "\n",
            "", "Bitrise Restore SPM Cache step not detected.", "\n",
            "", "Reading Xcode project app version...", "\n",
            "", "", "\n",
            "", "Reading Xcode project build number...", "\n",
            "", "0", "\n",
            "", "Building app configurations...", "\n",
            "", "Building app flavour \"Prod-Release\"...", "\n",
            "", "Archiving app...", "\n",
            "", "Preparing to upload dSYMs to AppCenter...", "\n",
            "", "Zipping dSYMs to file:///tmp/T-dSYMs.zip ...", "\n",
            "", "", "\n",
            "", "\u{1B}[1A\u{1B}[KProgress 100%", "\n",
            "", "Uploading dSYMs...", "\n",
            "", "", "\n",
            "", "\u{1B}[1A\u{1B}[KProgress 100%", "\n",
            "", "Uploading dSYMs finished with status created", "\n",
            "", "Writing export options plist...", "\n",
            "", "Exporting app...", "\n",
            "", "Skipping deploy...", "\n"
        ])
    }
    
    func testUpdateJiraWithoutAppCenterReleaseInstallURLs() async throws {
        //Given
        processInfoService.environment = [
            "JIRA_QA_COLUMN_ID" : "1",
        ]
        gitService.fetchBranchResult = .success(.init(name: "feature/PR-1234/ios"))
        atlassianAPI.moveTicketToQAResults = [.success(())]
        atlassianAPI.commentOnTicketResults = [.success(())]
        let expectedJSON = """
        {
          "body" : {
            "version" : 1,
            "type" : "doc",
            "content" : [
              {
                "type" : "paragraph",
                "content" : [
                  {
                    "type" : "text",
                    "text" : "Ad hoc build v1.0.0 (1) for Live uploaded to AppCenter"
                  }
                ]
              }
            ]
          }
        }
        """
        //When
        try await actions.updateJira(comment: "Ad hoc build v1.0.0 (1) for Live uploaded to AppCenter", appCenterReleaseInstallURLs: [])
        
        //Then
        XCTAssertEqual(atlassianAPI.commentOnTicketCalls.count, 1)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let json = try jsonEncoder.encode(atlassianAPI.commentOnTicketCalls.first?.comment).stringUTF8
        XCTAssertEqual(expectedJSON, json)
    }
    
    func testUpdateJiraWithAppCenterReleaseInstallURLs() async throws {
        //Given
        processInfoService.environment = [
            "JIRA_QA_COLUMN_ID" : "1",
        ]
        gitService.fetchBranchResult = .success(.init(name: "feature/PR-1234/ios"))
        atlassianAPI.moveTicketToQAResults = [.success(())]
        atlassianAPI.commentOnTicketResults = [.success(())]
        let expectedJSON = """
        {
          "body" : {
            "version" : 1,
            "type" : "doc",
            "content" : [
              {
                "type" : "paragraph",
                "content" : [
                  {
                    "type" : "text",
                    "text" : "Ad hoc build v1.0.0 (1) for Live uploaded to AppCenter"
                  }
                ]
              },
              {
                "type" : "paragraph",
                "content" : [
                  {
                    "type" : "text",
                    "text" : "Select a flavour to install on your iPhone:",
                    "marks" : [
                      {
                        "type" : "em"
                      }
                    ]
                  }
                ]
              },
              {
                "type" : "paragraph",
                "content" : [
                  {
                    "type" : "text",
                    "text" : "Live",
                    "marks" : [
                      {
                        "type" : "link",
                        "attrs" : {
                          "href" : "http://google.com"
                        }
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
        """
        //When
        try await actions.updateJira(comment: "Ad hoc build v1.0.0 (1) for Live uploaded to AppCenter", appCenterReleaseInstallURLs: [(.init(appBundleIdSuffix: ".live", baseBundleId: "com.apple", label: "Live", labelIncludingRelease: "Live", name: "Live"), URL(string: "http://google.com")!)])
        
        //Then
        XCTAssertEqual(atlassianAPI.commentOnTicketCalls.count, 1)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let json = try jsonEncoder.encode(atlassianAPI.commentOnTicketCalls.first?.comment).stringUTF8
        XCTAssertEqual(expectedJSON, json)
    }
}
