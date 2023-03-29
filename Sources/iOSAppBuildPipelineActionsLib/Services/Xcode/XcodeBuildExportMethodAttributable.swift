import Foundation

public protocol XcodeBuildExportMethodAttributable {
    
    var bitriseWorkflowIdComponent: String { get }
    var installServiceProviderName: String { get }
}

extension XcodeBuildExportMethod: XcodeBuildExportMethodAttributable {
    
    public var bitriseWorkflowIdComponent: String { "" }
    public var installServiceProviderName: String { "" }
}
