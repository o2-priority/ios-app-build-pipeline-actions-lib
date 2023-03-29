import Foundation

public struct Atlassian {
    
    public struct ContentRepsonse: Codable, Equatable {
        
        struct Link: Codable, Equatable {
            
            var base: String
            var webui: String
        }
        
        var id: String
        var _links: Link
    }

    public struct Page: Codable, Equatable {
        
        struct Space: Codable, Equatable {
            
            var key: String
        }
        
        struct Ancestor: Codable, Equatable {
            
            var id: String
        }
        
        struct Body: Codable, Equatable {
            
            struct Storage: Codable, Equatable {
                
                var value: String
                var representation: Representation
            }
            
            var storage: Storage
            
            init(value: String, representation: Representation) {
                storage = .init(value: value, representation: representation)
            }
        }
        
        var type: String
        var title: String
        var space: Space
        var ancestors: [Ancestor]
        var body: Body
        
        init(title: String, space: String, ancestor: String, content: String, representation: Representation) {
            self.type = "page"
            self.title = title
            self.space = Space(key: space)
            self.ancestors = [Ancestor(id: ancestor)]
            self.body = .init(value: content, representation: representation)
        }
    }
    
    public struct Credentials: Equatable {
        
        var userName: String
        var token: String
        
        public init(userName: String, token: String) {
            self.userName = userName
            self.token = token
        }
    }
    
    public struct TransitionBody: Codable, Equatable {
        
        internal struct Transition: Codable, Equatable {
            
            var id: String
        }
        
        var transition: Transition
        
        init(id: String) {
            transition = .init(id: id)
        }
    }
    
    public struct AtlassianDocumentFormat: Codable, Equatable {
        
        enum ADFType: String, Codable, Equatable {
            case doc
            case paragraph
            case text
        }
        
        struct Content: Codable, Equatable {
            struct Paragraph: Codable, Equatable {
                struct Mark: Codable, Equatable {
                    enum Option: String, Codable, Equatable {
                        case em
                        case link
                    }
                    struct Attrs: Codable, Equatable {
                        var href: URL
                    }
                    var type: Option
                    var attrs: Attrs?
                }
                var type: ADFType = .text
                var text: String
                var marks: [Mark]?
            }
            var type: ADFType = .paragraph
            var content: [Paragraph]
        }
        
        var version: Int = 1
        var type: ADFType = .doc
        var content: [Content]
    }
    
    public struct Comment: Codable, Equatable {
        
        var body: AtlassianDocumentFormat
    }
    
    public enum Representation: String, Codable {
        case storage = "storage" //Confluence Storage Format reference https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html
        case wiki = "wiki" //Confluence Wiki Markup reference https://support.atlassian.com/confluence-cloud/docs/insert-confluence-wiki-markup/
    }
}
