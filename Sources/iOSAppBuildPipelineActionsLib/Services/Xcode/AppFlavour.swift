import Foundation

public struct AppFlavour: Equatable, Hashable {
    
    let appBundleIdSuffix: String
    let baseBundleId: String
    let label: String
    let labelIncludingRelease: String
    public let name: String
    
    public init(appBundleIdSuffix: String, baseBundleId: String, label: String, labelIncludingRelease: String, name: String) {
        self.appBundleIdSuffix = appBundleIdSuffix
        self.baseBundleId = baseBundleId
        self.label = label
        self.labelIncludingRelease = labelIncludingRelease
        self.name = name
    }
}
