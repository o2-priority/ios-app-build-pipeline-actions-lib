import Foundation

public struct Atlassian {
    
    public struct Comment: Codable, Equatable {
        
        var body: AtlassianDocumentFormat
    }
    
    public struct Credentials: Equatable {
        
        var userName: String
        var token: String
        
        public init(userName: String, token: String) {
            self.userName = userName
            self.token = token
        }
    }

    public struct Page: Codable, Equatable {
        
        struct JSON2StringError: Error {}
        
        enum Status: String, Codable, Equatable {
            case current
            case draft
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
        
        var spaceId: String
        var status: Status
        var title: String
        var parentId: String
        var body: Body
        
        init(spaceId: String, status: Status, title: String, parentId: String, atlasDocFormat: AtlassianDocumentFormat) throws {
            self.spaceId = spaceId
            self.status = status
            self.title = title
            self.parentId = parentId
            guard let value = try JSONEncoder().encode(atlasDocFormat).stringUTF8 else {
                throw JSON2StringError()
            }
            self.body = .init(value: value, representation: .atlasDocFormat)
        }
        
        init(spaceId: String, status: Status, title: String, parentId: String, storage: String) {
            self.spaceId = spaceId
            self.status = status
            self.title = title
            self.parentId = parentId
            self.body = .init(value: storage, representation: .storage)
        }
        
        init(spaceId: String, status: Status, title: String, parentId: String, wiki: String) {
            self.spaceId = spaceId
            self.status = status
            self.title = title
            self.parentId = parentId
            self.body = .init(value: wiki, representation: .wiki)
        }
    }
    
    public struct PageResponse: Codable, Equatable {
        
        var id: String
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
    
    /**
     https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/#json-schema
     */
    public struct AtlassianDocumentFormat: Codable, Equatable {
        
        var version: Int = 1
        var type = "doc"
        var content: [Content]
        
        enum Content: Codable, Equatable {
            
            /**
             Top-level block nodes
             https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/#top-level-block-nodes
             */
            case codeBlock([Content])
            case paragraph([Content])
            
            /**
             Inline nodes
             https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/#inline-nodes
             */
            case hardBreak
            case text(Text)
            
            enum ADFType: String, Codable, Equatable {
                case codeBlock
                case hardBreak
                case paragraph
                case text
            }
            
            enum CodingKeys: String, CodingKey {
                case type
                case content
                
                //Text
                case text
                case marks
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                let type = try values.decode(ADFType.self, forKey: .type)
                switch type {
                case .codeBlock:
                    self = .codeBlock(try values.decode([Content].self, forKey: .content))
                case .hardBreak:
                    self = .hardBreak
                case .paragraph:
                    self = .paragraph(try values.decode([Content].self, forKey: .content))
                case .text:
                    self = .text(.init(
                        text: try values.decode(String.self, forKey: .text),
                        marks: try values.decodeIfPresent([Text.Mark].self, forKey: .marks)
                    ))
                }
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .codeBlock(content):
                    try container.encode(ADFType.codeBlock, forKey: .type)
                    try container.encode(content, forKey: .content)
                case .hardBreak:
                    try container.encode(ADFType.hardBreak, forKey: .type)
                case let .paragraph(content):
                    try container.encode(ADFType.paragraph, forKey: .type)
                    try container.encode(content, forKey: .content)
                case let .text(text):
                    try container.encode(ADFType.text, forKey: .type)
                    try container.encode(text.text, forKey: .text)
                    try container.encodeIfPresent(text.marks, forKey: .marks)
                }
            }
            
            struct CodeBlock: Codable, Equatable {
                
                var content: [Content]
            }
            
            struct Paragraph: Codable, Equatable {
                
                var content: [Content]
            }
            
            struct Text: Codable, Equatable {
                var type = "text"
                var text: String
                var marks: [Mark]?
                
                struct Mark: Codable, Equatable {
                    enum Option: String, Codable, Equatable {
                        case code
                        case em
                        case link
                        case strong
                    }
                    struct Attrs: Codable, Equatable {
                        var href: URL
                    }
                    var type: Option
                    var attrs: Attrs?
                }
            }
        }
    }
    
    public enum Representation: String, Codable {
        case atlasDocFormat = "atlas_doc_format" //Atlassian Document Format (ADF) https://developer.atlassian.com/cloud/jira/platform/apis/document/playground/
        case storage = "storage" //Confluence Storage Format reference https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html
        case wiki = "wiki" //Confluence Wiki Markup reference https://support.atlassian.com/confluence-cloud/docs/insert-confluence-wiki-markup/
    }
}
