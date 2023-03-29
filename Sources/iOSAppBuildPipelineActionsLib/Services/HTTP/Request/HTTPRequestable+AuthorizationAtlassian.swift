import Foundation

public protocol AuthorizationAtlassian {}

extension HTTPRequestable where Self: AuthorizationAtlassian {
    
    mutating func addAuthorizationHeader(credentials: Atlassian.Credentials) throws {
        guard let base64LoginString = "\(credentials.userName):\(credentials.token)".data(using: .utf8)?.base64EncodedString() else {
            throw ActionsError.malformedInput(description: "Either username\(credentials.userName) or token(\(credentials.token)) has malformed string")
        }
        headers["Authorization"] = "Basic \(base64LoginString)"
    }
}
