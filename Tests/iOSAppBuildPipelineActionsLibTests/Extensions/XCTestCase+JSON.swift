import Foundation
import XCTest

extension XCTestCase {
    
    func getJSONData(from fileName: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            throw BundleURLForResourceError()
        }
        return try Data(contentsOf: url)
    }
}

struct BundleURLForResourceError: Error {}
