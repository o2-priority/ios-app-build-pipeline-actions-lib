import Foundation
import ArgumentParser

public enum XcodeBuildExportMethod: String, CaseIterable, ExpressibleByArgument {
    case development = "development"
    case enterprise = "enterprise"
    case adhoc = "ad-hoc"
    case appstore = "app-store"
    
    public var bitriseWorkflowIdComponent: String {
        switch self {
        case .development:
            return "development"
        case .enterprise:
            return "enterprise"
        case .adhoc:
            return "adhoc"
        case .appstore:
            return "appstore"
        }
    }
    
    public var displayText: String {
        switch self {
        case .development:
            return "Development"
        case .enterprise:
            return "Enterprise"
        case .adhoc:
            return "Ad hoc"
        case .appstore:
            return "Appstore"
        }
    }
    
    public var installServiceProviderName: String {
        switch self {
        case .development:
            return "Local"
        case .enterprise, .adhoc:
            return "AppCenter"
        case .appstore:
            return "TestFlight"
        }
    }
    
    public var schemeComponent: String {
        switch self {
        case .development:
            return "Xcode"
        case .enterprise:
            return "Enterprise"
        case .adhoc:
            return "Adhoc"
        case .appstore:
            return "Appstore"
        }
    }
    
    public var signingCertificate: XcodeBuildExportOptions.SigningCertificate {
        self == .development ? .automatic(.appleDevelopment) : .automatic(.iosDistribution)
    }
}
