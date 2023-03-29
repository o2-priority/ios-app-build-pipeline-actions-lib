import Foundation

extension Encodable {
    
    func asDictionary(using encoder: JSONEncoder) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: encoder.encode(self)) as? [String: Any] ?? [:]
    }
}

extension Dictionary where Key == String, Value == Any {
    
    var queryItems: [URLQueryItem] {
        compactMap { key, value in
            switch value {
            case let string as String:
                return .init(name: key, value: string)
            case let int as Int:
                return .init(name: key, value: String(int))
            default:
                return nil
            }
        }.sorted { a, b in
            if a.name == b.name {
                return (a.value ?? "") < (b.value ?? "")
            } else {
                return a.name < b.name
            }
        }
    }
}
