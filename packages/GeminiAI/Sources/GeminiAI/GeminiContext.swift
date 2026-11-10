import Foundation

public struct ChatMessageSnippet {
    public let sender: String
    public let text: String
    public let timestamp: Date
    public let isOutgoing: Bool
    
    public init(sender: String, text: String, timestamp: Date = Date(), isOutgoing: Bool = false) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.isOutgoing = isOutgoing
    }
}

public struct GeminiChatContext {
    public let chatTitle: String
    public let chatType: String // "Direct Message", "Group Chat", "Channel", "Bot"
    public let recentMessages: [ChatMessageSnippet]
    public let selectedMessage: ChatMessageSnippet?
    
    public init(chatTitle: String, chatType: String = "Chat", recentMessages: [ChatMessageSnippet] = [], selectedMessage: ChatMessageSnippet? = nil) {
        self.chatTitle = chatTitle
        self.chatType = chatType
        self.recentMessages = recentMessages
        self.selectedMessage = selectedMessage
    }
    
    public func formattedHistory(maxCount: Int = 50) -> String {
        let slice = recentMessages.suffix(maxCount)
        guard !slice.isEmpty else { return "(No recent messages available)" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return slice.map { msg in
            let time = formatter.string(from: msg.timestamp)
            return "[\(time)] \(msg.sender): \(msg.text)"
        }.joined(separator: "\n")
    }
}
