import Foundation

extension SlackAPI {
    
    public enum Block: Encodable {
        case section(BlockSection)
        case context(BlockContext)
        case actions(BlockActions)
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .section(let blockSection):
                try container.encode(blockSection)
            case .context(let blockContext):
                try container.encode(blockContext)
            case .actions(let blockActions):
                try container.encode(blockActions)
            }
        }
    }
    
    public struct BlockSection: Encodable {
        let type = "section"
        let text: BlockTextMarkdown
    }
    
    public struct BlockTextPlainText: Encodable {
        let type = "plain_text"
        let text: String
        let emoji: Bool
    }
    
    public struct BlockTextMarkdown: Encodable {
        let type = "mrkdwn"
        let text: String
    }
    
    public struct BlockContext: Encodable {
        let type = "context"
        let elements: [BlockTextMarkdown]
        
        init(text: String) {
            elements = [.init(text: text)]
        }
    }
    
    public struct BlockActions: Encodable {
        let type = "actions"
        let elements: [BlockButton]
    }
    
    public struct BlockButton: Encodable {
        let type = "button"
        let text: BlockTextPlainText
        let url: String
    }
}
