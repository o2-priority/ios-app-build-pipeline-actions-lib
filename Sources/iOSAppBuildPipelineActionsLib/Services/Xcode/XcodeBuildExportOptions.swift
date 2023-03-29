import Foundation

public struct XcodeBuildExportOptions: Codable {
    
    public enum Destination: String {
        case export
        case upload
    }
    
    public enum SigningCertificate {
        
        public enum AutomaticSelector: String {
            case appleDevelopment = "Apple Development"
            case appleDistribution = "Apple Distribution"
            case developerIdApp = "Developer ID Application"
            case iosDeveloper = "iOS Developer"
            case iosDistribution = "iOS Distribution"
            case macDeveloper = "Mac Developer"
            case macDistribution = "Mac App Distribution"
        }
        
        case automatic(AutomaticSelector)
        case manual(certificateName: String)
        
        var value: String {
            switch self {
            case .automatic(let automaticSelector):
                return automaticSelector.rawValue
            case .manual(let certificateName):
                return certificateName
            }
        }
    }
    
    public enum SigningStyle: String {
        case automatic
        case manual
    }
    
    public enum Thinning: Equatable {
        case none
        case allVariants
        case singleVariant(modelIdentifier: String)
        
        var value: String {
            switch self {
            case .none:
                return "<none>"
            case .allVariants:
                return "<thin-for-all-variants>"
            case .singleVariant(let modelIdentifier):
                return modelIdentifier
            }
        }
    }
    
    public init(
        compileBitcode: Bool,
        destination: Destination,
        generateAppStoreInformation: Bool,
        manageAppVersionAndBuildNumber: Bool,
        method: XcodeBuildExportMethod,
        provisioningProfiles: [String : String],
        signingCertificate: XcodeBuildExportOptions.SigningCertificate,
        signingStyle: SigningStyle,
        stripSwiftSymbols: Bool,
        teamID: String,
        thinning: Thinning,
        uploadBitcode: Bool,
        uploadSymbols: Bool)
    {
        self.compileBitcode = compileBitcode
        self.destination = destination.rawValue
        self.generateAppStoreInformation = generateAppStoreInformation
        self.manageAppVersionAndBuildNumber = manageAppVersionAndBuildNumber
        self.method = method.rawValue
        self.provisioningProfiles = provisioningProfiles
        self.signingCertificate = signingCertificate.value
        self.signingStyle = signingStyle.rawValue
        self.stripSwiftSymbols = stripSwiftSymbols
        self.teamID = teamID
        self.thinning = thinning.value
        self.uploadBitcode = uploadBitcode
        self.uploadSymbols = uploadSymbols
    }
    
    /**
     For non-App Store exports, should Xcode re-compile the app from bitcode? Defaults to YES.
     */
    let compileBitcode: Bool
    
    /**
     Determines whether the app is exported locally or uploaded to Apple. Options are export or upload. The available options vary based on the selected distribution method. Defaults to export.
     */
    let destination: String
    
    /**
     For App Store exports, should Xcode generate App Store Information for uploading with iTMSTransporter? Defaults to NO.
     */
    let generateAppStoreInformation: Bool
    
    /**
     Should Xcode manage the app's build number when uploading to App Store Connect? Defaults to YES.
     */
    let manageAppVersionAndBuildNumber: Bool
    
    /**
     Describes how Xcode should export the archive. Available options: app-store, validation, ad-hoc, package, enterprise, development, developer-id, and mac-application. The list of options varies based on the type of archive. Defaults to development.
     */
    let method: String
    
    /**
     For manual signing only. Specify the provisioning profile to use for each executable in your app. Keys in this dictionary are the bundle identifiers of executables; values are the provisioning profile name or UUID to use.
     */
    let provisioningProfiles: [String : String]
    
    /**
     For manual signing only. Provide a certificate name, SHA-1 hash, or automatic selector to use for signing. Automatic selectors allow Xcode to pick the newest installed certificate of a particular type. The available automatic selectors are "Mac App Distribution", "iOS Distribution", "iOS Developer", "Developer ID Application", "Apple Distribution", "Mac Developer", and "Apple Development". Defaults to an automatic certificate selector matching the current distribution method.
     */
    let signingCertificate: String
    
    /**
     The signing style to use when re-signing the app for distribution. Options are manual or automatic. Apps that were automatically signed when archived can be signed manually or automatically during distribution, and default to automatic. Apps that were manually signed when archived must be manually signed during distribtion, so the value of signingStyle is ignored.
     */
    let signingStyle: String
    
    /**
     Should symbols be stripped from Swift libraries in your IPA? Defaults to YES.
     */
    let stripSwiftSymbols: Bool
    
    /**
     The Developer Portal team to use for this export. Defaults to the team used to build the archive.
     */
    let teamID: String
    
    /**
     For non-App Store exports, should Xcode thin the package for one or more device variants? Available options: <none> (Xcode produces a non-thinned universal app), <thin-for-all-variants> (Xcode produces a universal app and all available thinned variants), or a model identifier for a specific device (e.g. "iPhone7,1"). Defaults to <none>.
     */
    let thinning: String
    
    /**
     For App Store exports, should the package include bitcode? Defaults to YES.
     */
    let uploadBitcode: Bool
    
    /**
     For App Store exports, should the package include symbols? Defaults to YES.
     */
    let uploadSymbols: Bool
}

