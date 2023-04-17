import Foundation
import PathKit
import ZIPFoundation

public final class Actions<T>: NSObject where T: RedactableTextOutputStream {
    
    private let appCenterAPI: AppCenterAPIProtocol
    private let atlassianAPI: AtlassianAPIProtocol
    private let bitriseAPI: BitriseAPIProtocol
    private let buildNumberAPI: BuildNumberAPIProtocol
    private let fileManagerService: FileManagerServiceProtocol
    private let gitHubAPI: GitHubAPIProtocol
    private let gitService: GitServiceProtocol
    private let processInfoService: ProcessInfoServiceProtocol
    private let slackAPI: SlackAPIProtocol
    private let xcodeService: XcodeServiceProtocol
    private var textOutputStream: T
    private let isCI: Bool
    private let progressFormatter = NumberFormatter()
    @objc dynamic private let zipProgress = Progress()
    
    public init(appCenterAPI: AppCenterAPIProtocol,
                atlassianAPI: AtlassianAPIProtocol,
                bitriseAPI: BitriseAPIProtocol,
                buildNumberAPI: BuildNumberAPIProtocol,
                fileManagerService: FileManagerServiceProtocol,
                gitHubAPI: GitHubAPIProtocol,
                gitService: GitServiceProtocol,
                processInfoService: ProcessInfoServiceProtocol,
                slackAPI: SlackAPIProtocol,
                xcodeService: XcodeServiceProtocol,
                textOutputStream: T,
                isCI: Bool)
    {
        self.appCenterAPI = appCenterAPI
        self.atlassianAPI = atlassianAPI
        self.bitriseAPI = bitriseAPI
        self.buildNumberAPI = buildNumberAPI
        self.fileManagerService = fileManagerService
        self.gitHubAPI = gitHubAPI
        self.gitService = gitService
        self.processInfoService = processInfoService
        self.slackAPI = slackAPI
        self.xcodeService = xcodeService
        self.textOutputStream = textOutputStream
        self.isCI = isCI
        progressFormatter.maximumFractionDigits = 0
        progressFormatter.numberStyle = .percent
        super.init()
        addObserver(self, forKeyPath: #keyPath(zipProgress.fractionCompleted), options: [.new], context: nil)
    }
    
    public func preBuildAndDeploy(_ input: PreBuildAndDeployParameters, buildAndDeployParameters: BuildAndDeployParameters) async throws
    {
        let environment = processInfoService.environment
        guard try gitService.isWorkingDirectoryClean() else {
            throw ReleaseError.gitWorkingDirectoryIsDirty
        }
        let currentBranch = try gitService.fetchCurrentBranch()
        let kConfluenceParentPageId = "CONFLUENCE_RELEASE_NOTES_PARENT_PAGE_ID"
        if currentBranch.name.hasPrefix("release/"), environment[kConfluenceParentPageId] == nil {
            throw ReleaseError.envVarNotFound(kConfluenceParentPageId)
        }
        
        // Run unit tests
        if !input.skipTest {
            try await Test(xcodeService: xcodeService, textOutputStream: textOutputStream).test(.init(
                schemeLocation: input.schemeLocation,
                scheme: input.schemeForTest,
                simulatorRuntimes: input.simulatorRuntimes,
                preferredSimulatorNames: input.preferredSimulatorNames,
                codeCoverageTarget: "\(input.target).app",
                reportOutputDir: input.buildOutputDir)
            )
        } else {
            print("Skipping unit tests...", to: &textOutputStream)
        }
        
        // Get Xcode project target app version
        print("Reading Xcode project app version...", to: &textOutputStream)
        let appVersion = try xcodeService.getAppVersion(xcodeProjPath: input.schemeLocation.path, target: input.target, configuration: input.appStoreReleaseConfiguration)
        print("\(appVersion)", to: &textOutputStream)
        
        // Get build number
        let buildNumber: Int
        switch input.buildNumberOption {
        case .fetch(let numberId):
            print("Requesting next build number...", to: &textOutputStream)
            buildNumber = try await buildNumberAPI.getNextBuildNumber(numberId: numberId)
        case .local(let localBuildNumber):
            buildNumber = localBuildNumber
        }
        
        // Set Xcode project target build number
        print("Setting Xcode project build number to \(buildNumber)", to: &textOutputStream)
        try xcodeService.setBuildNumber(buildNumber, xcodeProjPath: input.schemeLocation.path, target: input.target)
        
        // Prepare release notes
        guard let confluenceParentPageId = environment[kConfluenceParentPageId] else {
            throw ReleaseError.envVarNotFound(kConfluenceParentPageId)
        }
        let exportMethod = input.exportMethod
        try await prepareReleaseNotes(
            currentBranch: currentBranch,
            try .init(environments: input.appFlavours.map { $0.labelIncludingRelease }.joined(separator: ", "),
                      distributionMethod: exportMethod.displayText,
                      confluenceParentPageId: confluenceParentPageId,
                      pageTitle: "v\(appVersion) (\(buildNumber))",
                      gitHubOwner: buildAndDeployParameters.gitHubOwner,
                      gitHubRepo: buildAndDeployParameters.gitHubRepo),
            textOutputStream: &textOutputStream
        )
        
        // Commit new version and push
        let branch = try gitService.fetchCurrentBranch().name
        try gitService.commit(subject: "v\(appVersion) (\(buildNumber))", body: input.buildJobInfo)
        try gitService.push(remote: "origin", branch: branch)
        
        // Build app configurations
        for appFlavour in input.appFlavours {
            if isCI {
                let triggerBuildResponse = try await bitriseAPI.triggerBuild(
                    .init(buildParams: .init(
                        branch: branch,
                        workflowId: [
                            "deploy",
                            input.exportMethod.bitriseWorkflowIdComponent,
                            appFlavour.name
                        ].joined(separator: "-"))
                    )
                )
                print(triggerBuildResponse, to: &textOutputStream)
            } else {
                try await buildAndDeploy(buildAndDeployParameters)
            }
        }
    }
    
    public func buildAndDeploy(_ input: BuildAndDeployParameters) async throws
    {
        let environment = processInfoService.environment
        let exportMethod = input.exportMethod
        guard try gitService.isWorkingDirectoryClean() else {
            throw ReleaseError.gitWorkingDirectoryIsDirty
        }
        let kAppCenterOwnerName = "APPCENTER_OWNER_NAME"
        guard let ownerName = environment[kAppCenterOwnerName] else {
            throw ReleaseError.envVarNotFound(kAppCenterOwnerName)
        }
        // Get Xcode project target app version
        print("Reading Xcode project app version...", to: &textOutputStream)
        let appVersion = try xcodeService.getAppVersion(xcodeProjPath: input.schemeLocation.path, target: input.target, configuration: input.appStoreReleaseConfiguration)
        print("\(appVersion)", to: &textOutputStream)
        
        // Get Xcode project target build number
        print("Reading Xcode project build number...", to: &textOutputStream)
        let buildNumber = try xcodeService.getBuildNumber(xcodeProjPath: input.schemeLocation.path, target: input.target, configuration: input.appStoreReleaseConfiguration)
        print("\(buildNumber)", to: &textOutputStream)
        
        // Build app configurations
        print("Building app configurations...", to: &textOutputStream)
        var appCenterReleaseInstallURLs: [(AppFlavour, URL)] = []
        for appFlavour in input.appFlavours {
            let appConfiguration = try input.appConfigurationBuilder.appConfiguration(flavour: appFlavour, distributionMethod: exportMethod, version: appVersion, buildNumber: buildNumber)
            print(#"Building app flavour "\#(appFlavour.labelIncludingRelease)"..."#, to: &textOutputStream)
            let destination = #""generic/platform=iOS""#
            try await xcodeService.build(
                schemeLocation: input.schemeLocation,
                scheme: appConfiguration.scheme,
                destination: destination,
                textOutputStream: &textOutputStream
            )
            print("Archiving app...", to: &textOutputStream)
            let archivePath = appConfiguration.archivePath(baseDir: input.buildOutputDir)
            try await xcodeService.archive(
                schemeLocation: input.schemeLocation,
                scheme: appConfiguration.scheme,
                destination: destination,
                sdk: "iphoneos",
                archivePath: archivePath,
                textOutputStream: &textOutputStream)
            switch exportMethod {
            case .adhoc, .appstore, .enterprise:
                print("Preparing to upload dSYMs to AppCenter...", to: &textOutputStream)
                do {
                    try await appCenterUploadSymbols(
                        ownerName: ownerName,
                        appName: appConfiguration.appCenterAppName,
                        archivePath: archivePath)
                } catch {
                    print("Uploading dSYMs to AppCenter failed: \(error.localizedDescription)", to: &textOutputStream)
                    print("Recovery advice: manually upload the dSYMs found in the Artifacts directory.", to: &textOutputStream)
                }
            case .development:
                break
            }
            print("Writing export options plist...", to: &textOutputStream)
            let exportOptionsPlistPath = appConfiguration.exportOptionsPlistPath(baseDir: input.buildOutputDir)
            try xcodeService.writeExportOptionsPlist(
                appConfiguration.exportOptions,
                exportOptionsPlist: exportOptionsPlistPath
            )
            print("Exporting app...", to: &textOutputStream)
            let exportPath = appConfiguration.exportPath(baseDir: input.buildOutputDir)
            try await xcodeService.exportArchive(
                archivePath: archivePath,
                exportPath: exportPath,
                exportOptionsPlist: exportOptionsPlistPath,
                textOutputStream: &textOutputStream)
            if input.skipDeploy { continue }
            // Upload app binary to AppCenter or TestFlight
            let ipaPath = exportPath + Path("\(input.bundleDisplayName).ipa")
            switch exportMethod {
            case .appstore:
                let kAppLoaderUsername = "ALTOOL_USERNAME"
                guard let alToolUsername = environment[kAppLoaderUsername] else {
                    throw ReleaseError.envVarNotFound(kAppLoaderUsername)
                }
                let kAppLoaderPassword = "ALTOOL_PASSWORD"
                guard let alToolPassword = environment[kAppLoaderPassword] else {
                    throw ReleaseError.envVarNotFound(kAppLoaderPassword)
                }
                textOutputStream.redact(string: alToolPassword)
                try await xcodeService.uploadPackage(
                    ipaPath: ipaPath,
                    appAppleId: appConfiguration.appAppleId,
                    bundleVersion: "\(buildNumber)",
                    bundleShortVersion: appVersion,
                    bundleId: appConfiguration.bundleId,
                    auth: .basic(.init(username: alToolUsername,
                                       password: alToolPassword)),
                    textOutputStream: &textOutputStream)
            case .adhoc, .enterprise:
                let installURL = try await appCenterUploadRelease(
                    appName: appConfiguration.appCenterAppName,
                    archivePath: archivePath,
                    ipaPath: ipaPath,
                    distributionGroups: appConfiguration.appCenterDistributionGroups,
                    environment: environment)
                appCenterReleaseInstallURLs.append((appFlavour, installURL))
            case .development:
                break
            }
        }
        guard !input.skipDeploy else { print("Skipping deploy...", to: &textOutputStream); return }
        if exportMethod == .adhoc || exportMethod == .enterprise {
            print("AppCenter upload release results:", to: &textOutputStream)
            appCenterReleaseInstallURLs.forEach { (key, value) in
                print("\(key.labelIncludingRelease): \(value)", to: &textOutputStream)
            }
        }
        let buildSummary = "\(input.exportMethod.displayText) build v\(appVersion) (\(buildNumber)) for \(input.appFlavours.map { $0.labelIncludingRelease }.joined(separator: ", ")) uploaded to \(exportMethod.installServiceProviderName)"
        if input.skipJira { print("Skipping Jira...", to: &textOutputStream); return }
        try await updateJira(comment: buildSummary, appCenterReleaseInstallURLs: appCenterReleaseInstallURLs)
        if input.skipSlack { print("Skipping Slack...", to: &textOutputStream); return }
        try await slackBuildSummary(buildSummary, appCenterReleaseInstallURLs: appCenterReleaseInstallURLs, exportMethod: exportMethod, environment: environment)
    }
    
    private func prepareReleaseNotes<T: TextOutputStream>(
        currentBranch: Git.Branch,
        _ input: ReleaseNotesParameters,
        textOutputStream: inout T) async throws
    {
        print("Preparing release notes...", to: &textOutputStream)
        if currentBranch.name.hasPrefix("release/") {
            //Confluence Storage Format reference https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html
            let formattedContentString = """
            <strong>Branch:</strong> \(currentBranch)
            <strong>Environments:</strong> \(input.environments)
            <strong>Distribution method:</strong> \(input.distributionMethod)
            """
            let confluencePage = Atlassian.Page(title: input.pageTitle,
                                                space: "PD",
                                                ancestor: input.confluenceParentPageId,
                                                content: formattedContentString,
                                                representation: .storage)
            let contentResponse = try await atlassianAPI.postReleaseNotes(confluencePage)
            print("Branch: \(currentBranch.name)\n\(contentResponse._links.base)\(contentResponse._links.webui)", to: &textOutputStream)
        } else {
            let pullRequests = try await gitHubAPI.pullRequest(owner: input.gitHubOwner, repo: input.gitHubRepo, branchName: currentBranch.name)
            if let pullRequest = pullRequests.first {
                print("Branch name: \(currentBranch)\n\(pullRequest.html_url)", to: &textOutputStream)
            } else {
                print("No pull request found.", to: &textOutputStream)
            }
        }
    }
    
    private func appCenterUploadRelease(appName: String, archivePath: Path, ipaPath: Path, distributionGroups: [String], environment: [String : String]) async throws -> URL
    {
        print("Uploading ipa to AppCenter...", to: &textOutputStream)
        let kAppCenterOwnerName = "APPCENTER_OWNER_NAME"
        guard let ownerName = environment[kAppCenterOwnerName] else {
            throw ReleaseError.envVarNotFound(kAppCenterOwnerName)
        }
        print("Creating new release...", to: &textOutputStream)
        let newReleaseUploadCreated = try await appCenterAPI.newReleaseUpload(.init(ownerName: ownerName, appName: appName))
        print("Setting release metadata...", to: &textOutputStream)
        let fileSize = try fileManagerService.sizeOfFile(atPath: ipaPath.string)
        let releaseUploadInfo = try await appCenterAPI.setReleaseUploadMetadata(for: newReleaseUploadCreated, fileName: ipaPath.lastComponent, fileSize: Int(fileSize))
        print("Uploading...", to: &textOutputStream)
        let fileHandle = try fileManagerService.fileHandle(forReadingFrom: .init(fileURLWithPath: ipaPath.string))
        var chunkNumber = 0
        while true {
            if let chunk = try fileHandle.read(upToCount: releaseUploadInfo.chunkSize), !chunk.isEmpty {
                chunkNumber += 1
                print("Uploading chunk \(chunkNumber) of \(releaseUploadInfo.chunkList.count)...", to: &textOutputStream)
                print("", to: &textOutputStream)
                try await appCenterAPI.releaseUploadChunk(for: newReleaseUploadCreated, chunkNumber: chunkNumber, body: chunk, progress: printProgress)
                printProgress(1)
            } else {
                try await appCenterAPI.finishReleaseUpload(for: newReleaseUploadCreated)
                break
            }
        }
        print("Updating release status to complete...", to: &textOutputStream)
        _ = try await appCenterAPI.updateReleaseUploadStatus(.init(ownerName: ownerName, appName: appName, uploadId: newReleaseUploadCreated.id, body: .init(uploadStatus: .uploadFinished)))
        print("Fetching upload release...", to: &textOutputStream)
        let uploadRelease = try await getUploadRelease(.init(ownerName: ownerName, appName: appName, uploadId: newReleaseUploadCreated.id))
        guard let releaseId = uploadRelease.releaseDistinctId else {
            throw ReleaseError.appCenterReleaseFailure("API contract broken for status: \(uploadRelease.uploadStatus)")
        }
        print("Setting distribution groups...", to: &textOutputStream)
        _ = try await appCenterAPI.patchRelease(.init(ownerName: ownerName, appName: appName, releaseId: String(releaseId), body: .init(destinations: distributionGroups.map { .init(name: $0) }, mandatoryUpdate: false, notifyTesters: false, releaseNotes: "")))
        guard let releaseUrl = URL(string: "https://install.appcenter.ms/orgs/\(ownerName)/apps/\(appName)/releases/\(releaseId)") else {
            throw ReleaseError.appCenterReleaseFailure("Malformed release URL")
        }
        return releaseUrl
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(zipProgress.fractionCompleted), let fractionCompleted = change?[.newKey] as? Double {
            printProgress(fractionCompleted)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func appCenterUploadSymbols(ownerName: String, appName: String, archivePath: Path) async throws {
        let dSYMsZipFileUrl = fileManagerService.temporaryDirectory.appendingPathComponent("\(archivePath.url.deletingPathExtension().lastPathComponent)-dSYMs.zip")
        print("Zipping dSYMs to \(Path(dSYMsZipFileUrl.absoluteString).string) ...", to: &textOutputStream)
        print("", to: &textOutputStream)
        try fileManagerService.zipItem(at: (archivePath + Path("dSYMs")).url, to: dSYMsZipFileUrl, shouldKeepParent: false, compressionMethod: .deflate, progress: zipProgress)
        while !(zipProgress.isFinished || zipProgress.isCancelled) {}
        defer {
            do {
                try fileManagerService.removeItem(at: dSYMsZipFileUrl)
            } catch {
                print("Deleting \(Path(dSYMsZipFileUrl.absoluteString).string) failed with error: \(error.localizedDescription)", to: &textOutputStream)
            }
        }
        print("Uploading dSYMs...", to: &textOutputStream)
        let symbolsUpload = try await appCenterAPI.beginSymbolsUpload(.init(ownerName: ownerName, appName: appName, body: .init(symbolType: .apple, fileName: dSYMsZipFileUrl.lastPathComponent)))
        let symbolsUploadStatus: AppCenterAPI.FinishSymbolsUploadParameters.Body.Status
        do {
            print("", to: &textOutputStream)
            try await appCenterAPI.symbolsUpload(file: dSYMsZipFileUrl, uploadUrl: symbolsUpload.uploadUrl, progress: printProgress)
            printProgress(1)
            symbolsUploadStatus = .committed
        } catch {
            symbolsUploadStatus = .aborted
        }
        let finishSymbolsUpload = try await appCenterAPI.finishSymbolsUpload(.init(ownerName: ownerName, appName: appName, symbolUploadId: symbolsUpload.symbolUploadId, body: .init(status: symbolsUploadStatus)))
        print("Uploading dSYMs finished with status \(finishSymbolsUpload.status)", to: &textOutputStream)
    }
    
    private func printProgress(_ progress: Double) {
        guard !isCI else { return }
        print("\u{1B}[1A\u{1B}[KProgress \(progressFormatter.string(from: .init(value: progress)) ?? "")", to: &textOutputStream)
    }
    
    private func getUploadRelease(_ params: AppCenterAPI.GetUploadReleaseParameters) async throws -> AppCenterAPI.GetUploadReleaseResponse
    {
        let start = Date()
        let retryInterval: TimeInterval = 10
        let timeout = retryInterval * 12
        var failureMessage = ""
        while Date().timeIntervalSince(start) < timeout {
            try await Task.sleep(nanoseconds: UInt64(retryInterval * Double(NSEC_PER_SEC)))
            let uploadRelease = try await appCenterAPI.getUploadRelease(params)
            switch uploadRelease.uploadStatus {
            case .uploadStarted, .uploadFinished:
                failureMessage = uploadRelease.uploadStatus.rawValue
                print("Fetching upload release (retrying in \(retryInterval)s)...", to: &textOutputStream)
                continue
            case .uploadCanceled, .malwareDetected:
                failureMessage = uploadRelease.uploadStatus.rawValue
                break
            case .error:
                if let errorDetails = uploadRelease.errorDetails {
                    failureMessage = errorDetails
                } else {
                    failureMessage = "API contract broken for status: \(uploadRelease.uploadStatus)"
                }
                break
            case .readyToBePublished:
                return uploadRelease
            }
        }
        throw ReleaseError.appCenterReleaseFailure(failureMessage)
    }
    
    func updateJira(comment: String, appCenterReleaseInstallURLs: [(AppFlavour, URL)]) async throws {
        let environment = processInfoService.environment
        let kJiraQAColumnId = "JIRA_QA_COLUMN_ID"
        guard let jiraQAColumnId = environment[kJiraQAColumnId], jiraQAColumnId.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            throw ReleaseError.envVarNotFound(kJiraQAColumnId)
        }
        print("Updating Jira...", to: &textOutputStream);
        let currentBranch = try gitService.fetchCurrentBranch()
        if currentBranch.name.hasPrefix("release/") {
            return
        } else {
            let jiraTicketNumber = try currentBranch.parseJiraTicketNumber()
            try await atlassianAPI.moveTicketToQA(jiraTicketNumber, jiraQAColumnId: jiraQAColumnId)
            print("\(jiraTicketNumber) status updated to 'In QA'", to: &textOutputStream)
            if appCenterReleaseInstallURLs.isEmpty {
                let comment = Atlassian.Comment(
                    body: .init(content: [
                        .init(content: [
                            .init(text: comment)
                        ])
                    ])
                )
                try await atlassianAPI.commentOn(ticket: jiraTicketNumber, comment: comment)
            } else {
                for (appFlavour, installURL) in appCenterReleaseInstallURLs {
                    let comment = Atlassian.Comment(
                        body: .init(content: [
                            .init(content: [
                                .init(text: comment)
                            ]),
                            .init(content: [
                                .init(
                                    text: "Select a flavour to install on your iPhone:",
                                    marks: [.init(
                                        type: .em
                                    )]
                                )
                            ]),
                            .init(content: [
                                .init(
                                    text: appFlavour.labelIncludingRelease,
                                    marks: [.init(
                                        type: .link,
                                        attrs: .init(href: installURL)
                                    )]
                                )
                            ])
                        ])
                    )
                    try await atlassianAPI.commentOn(ticket: jiraTicketNumber, comment: comment)
                }
            }
            print("Comment with build details added to \(jiraTicketNumber)", to: &textOutputStream)
        }
    }
    
    private func slackBuildSummary(_ buildSummary: String, appCenterReleaseInstallURLs: [(AppFlavour, URL)], exportMethod: XcodeBuildExportMethod, environment: [String : String]) async throws
    {
        print("Slacking build summary...", to: &textOutputStream);
        let kSlackWebHookURL = "SLACK_WEBHOOK_URL"
        guard let slackWebHookURLString = environment[kSlackWebHookURL], let slackWebHookURL = URL(string: slackWebHookURLString) else {
            throw ReleaseError.envVarNotFound(kSlackWebHookURL)
        }
        textOutputStream.redact(string: slackWebHookURLString)
        var blocks: [SlackAPI.Block] = [.section(.init(text: .init(text: buildSummary)))]
        switch exportMethod {
        case .enterprise, .adhoc:
            blocks.append(contentsOf: [
                .context(.init(text: "Select a flavour to install on your iPhone:")),
                .section(.init(text: .init(text: appCenterReleaseInstallURLs.map { appFlavour, installURL in
                    "<\(installURL.absoluteString)|\(appFlavour.labelIncludingRelease)>"
                }.joined(separator: " - "))))
            ])
        case .appstore:
            blocks.append(contentsOf: [
                .context(.init(text: "<https://apps.apple.com/us/app/testflight/id899247664?platform=iphone|Open the Testflight app on your iPhone to install the app.>"))
            ])
        case .development:
            break
        }
        if let currentBranch = try? gitService.fetchCurrentBranch(),
           !currentBranch.name.hasPrefix("release/"),
           let jiraTicketNumber = try? currentBranch.parseJiraTicketNumber()
        {
            blocks.append(.context(.init(text: "Jira: <\(atlassianAPI.baseURLString)/browse/\(jiraTicketNumber)|\(jiraTicketNumber)>")))
        }
        try await slackAPI.incomingWebHook(url: slackWebHookURL, blocks: blocks)
    }
}

enum ReleaseError: Error {
    case envVarNotFound(String)
    case gitWorkingDirectoryIsDirty
    case targetNotFound
    case buildConfigurationNotFound
    case appVersionNotFound
    case buildNumberNotFound
    case buildNumberNotInt
    case appCenterReleaseFailure(String)
}

extension String {
    /**
     https://en.wikipedia.org/wiki/Character_encodings_in_HTML#XML_character_references
     */
    var XHTMLEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
