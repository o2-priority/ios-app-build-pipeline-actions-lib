import Foundation

public protocol AcceptJSON: Accept {}

extension HTTPRequestable where Self: AcceptJSON {
    
    mutating public func addAcceptHeader() {
        headers["Accept"] = "application/json"
    }
}
