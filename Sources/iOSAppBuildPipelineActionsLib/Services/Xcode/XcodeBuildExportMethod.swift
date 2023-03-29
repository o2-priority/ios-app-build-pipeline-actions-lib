import Foundation
import ArgumentParser

public enum XcodeBuildExportMethod: String, CaseIterable, ExpressibleByArgument {
    case development = "development"
    case enterprise = "enterprise"
    case adhoc = "ad-hoc"
    case appstore = "app-store"
    
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
