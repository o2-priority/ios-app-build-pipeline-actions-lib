import Foundation

public final class Test<T>: NSObject where T: RedactableTextOutputStream {
    
    private let xcodeService: XcodeServiceProtocol
    private var textOutputStream: T
    
    public init(xcodeService: XcodeServiceProtocol,
                textOutputStream: T)
    {
        self.xcodeService = xcodeService
        self.textOutputStream = textOutputStream
    }
    
    public func test(_ input: TestParameters) async throws
    {
        print("Testing app...", to: &textOutputStream)
        let simulatorIds = try xcodeService.getSimulatorIds(
            simulatorRuntimes: input.simulatorRuntimes,
            preferredSimulatorNames: input.preferredSimulatorNames,
            textOutputStream: &textOutputStream)
        var produceCodeCoverage = true
        for simulatorInfo in simulatorIds {
            try await xcodeService.test(
                schemeLocation: input.schemeLocation,
                scheme: input.scheme,
                destination: #""platform=iOS Simulator,id=\#(simulatorInfo.udid.uuidString)""#,
                simulatorRuntime: simulatorInfo.simulatorRuntime,
                codeCoverageTarget: produceCodeCoverage ? input.codeCoverageTarget : nil,
                reportOutputDir: input.reportOutputDir.url,
                textOutputStream: &textOutputStream
            )
            produceCodeCoverage = false
        }
    }
}
