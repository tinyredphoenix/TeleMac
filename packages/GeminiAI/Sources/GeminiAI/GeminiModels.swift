import Foundation

public struct GeminiModel: RawRepresentable, Equatable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static let flash20 = GeminiModel("gemini-2.0-flash")
    public static let pro15 = GeminiModel("gemini-1.5-pro")
    public static let flash15 = GeminiModel("gemini-1.5-flash")
    
    public var displayName: String {
        switch rawValue {
        case "gemini-2.0-flash":
            return "Gemini 2.0 Flash (Recommended)"
        case "gemini-1.5-pro":
            return "Gemini 1.5 Pro (Deep Analysis)"
        case "gemini-1.5-flash":
            return "Gemini 1.5 Flash (Fast)"
        default:
            return "Custom Agent / Model (\(rawValue))"
        }
    }
    
    public var isCustom: Bool {
        return self != .flash20 && self != .pro15 && self != .flash15
    }
}

public enum GeminiFeatureMode {
    case generalChat
    case summarizeChat
    case smartReply
    case rewrite(style: RewriteStyle)
    case translate(targetLanguage: String)
    case voiceTranscription
    case imageAnalysis
    case documentAnalysis
    case educationalVideoNotes
    
    public enum RewriteStyle: String {
        case shorter = "Make it shorter and more concise"
        case longer = "Expand and provide more detail"
        case formal = "Make it formal and professional"
        case casual = "Make it casual, friendly, and natural"
        case fixGrammar = "Fix all grammar, spelling, and phrasing errors"
    }
}

// MARK: - API Request & Response Types

public struct GeminiRequest: Encodable {
    public let contents: [GeminiContent]
    public let systemInstruction: GeminiSystemInstruction?
    public let generationConfig: GeminiGenerationConfig?
    
    public init(contents: [GeminiContent], systemInstruction: String? = nil, temperature: Float? = nil) {
        self.contents = contents
        if let systemInstruction = systemInstruction, !systemInstruction.isEmpty {
            self.systemInstruction = GeminiSystemInstruction(parts: [GeminiPart(text: systemInstruction)])
        } else {
            self.systemInstruction = nil
        }
        if let temp = temperature {
            self.generationConfig = GeminiGenerationConfig(temperature: temp)
        } else {
            self.generationConfig = nil
        }
    }
}

public struct GeminiSystemInstruction: Encodable {
    public let parts: [GeminiPart]
}

public struct GeminiGenerationConfig: Encodable {
    public let temperature: Float?
}

public struct GeminiContent: Codable {
    public let role: String?
    public let parts: [GeminiPart]
    
    public init(role: String? = "user", parts: [GeminiPart]) {
        self.role = role
        self.parts = parts
    }
}

public struct GeminiPart: Codable {
    public let text: String?
    public let inlineData: GeminiInlineData?
    
    public init(text: String) {
        self.text = text
        self.inlineData = nil
    }
    
    public init(mimeType: String, data: Data) {
        self.text = nil
        self.inlineData = GeminiInlineData(mimeType: mimeType, data: data.base64EncodedString())
    }
}

public struct GeminiInlineData: Codable {
    public let mimeType: String
    public let data: String
}

public struct GeminiResponse: Decodable {
    public let candidates: [GeminiCandidate]?
    public let error: GeminiApiError?
    
    public var firstText: String? {
        return candidates?.first?.content?.parts.compactMap { $0.text }.joined(separator: "")
    }
}

public struct GeminiCandidate: Decodable {
    public let content: GeminiContent?
    public let finishReason: String?
}

public struct GeminiApiError: Decodable {
    public let code: Int?
    public let message: String?
    public let status: String?
}

// MARK: - Video Study Notes Structure

public struct EducationalVideoNotes {
    public let summary: String
    public let keyTakeaways: [String]
    public let chapters: [VideoChapter]
    public let suggestedFollowUpQuestions: [String]
    
    public struct VideoChapter {
        public let timestamp: String
        public let title: String
        public let summary: String
    }
}
