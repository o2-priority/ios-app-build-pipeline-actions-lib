import Foundation

public var logURLRequests = false

extension URLRequest {
    
    func log<T>(textOutputStream: inout T) where T: RedactableTextOutputStream {
        if logURLRequests {
            print("\(httpMethod!) \(url!.absoluteString)", to: &textOutputStream)
            if allHTTPHeaderFields == nil {
                print(" No Headers")
            } else {
                allHTTPHeaderFields?.forEach { key, value in print(" \(key)=\(value)", to: &textOutputStream) }
            }
            if let utf8EncodedBody = httpBody?.stringUTF8 {
                print(" Body UTF-8: \(utf8EncodedBody)", to: &textOutputStream)
            } else if let bodySize = httpBody?.count {
                print(" Body size: \(bodySize)", to: &textOutputStream)
            } else {
                print(" No Body", to: &textOutputStream)
            }
        }
    }
}

extension Data {
    
    var stringUTF8: String? {
        String(data: self, encoding: .utf8)
    }
}
