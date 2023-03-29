import Foundation

@testable import iOSAppBuildPipelineActionsLib

final class MockBitriseAPI: BitriseAPIProtocol, API {
    
    func triggerBuild(_: BitriseAPI.BuildTriggerParams) async throws -> BitriseAPI.BuildTriggerResponse {
        .init(buildNumber: 0, buildSlug: "", buildUrl: "", message: "", service: "", slug: "", status: "", triggeredWorkflow: "")
    }
}
