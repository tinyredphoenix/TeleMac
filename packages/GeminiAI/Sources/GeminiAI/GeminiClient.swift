import Foundation

public enum GeminiClientError: LocalizedError {
    case missingApiKey
    case invalidURL
    case badResponse(statusCode: Int, message: String)
    case decodingError(Error)
    case emptyResponse
    
    public var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return "Gemini API key is not set. Please add your API key in Settings -> Gemini AI."
        case .invalidURL:
            return "Invalid Gemini endpoint URL."
        case let .badResponse(code, message):
            return "Gemini API error (\(code)): \(message)"
        case let .decodingError(err):
            return "Failed to parse Gemini response: \(err.localizedDescription)"
        case .emptyResponse:
            return "Gemini returned an empty response."
        }
    }
}

public final class GeminiClient {
    public static let shared = GeminiClient()
    
    private let session: URLSession
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Core Generate Content
    
    public func generate(
        prompt: String,
        context: GeminiChatContext? = nil,
        systemInstruction: String? = nil,
        model: GeminiModel = .flash20,
        temperature: Float? = nil
    ) async throws -> String {
        guard let apiKey = GeminiKeychain.load(), !apiKey.isEmpty else {
            throw GeminiClientError.missingApiKey
        }
        
        var effectivePrompt = prompt
        if let context = context {
            effectivePrompt = """
            [Current Conversation: \(context.chatTitle) (\(context.chatType))]
            Recent Message History:
            \(context.formattedHistory())
            
            User Request:
            \(prompt)
            """
        }
        
        let contents = [GeminiContent(parts: [GeminiPart(text: effectivePrompt)])]
        let requestBody = GeminiRequest(contents: contents, systemInstruction: systemInstruction, temperature: temperature)
        
        let endpoint = "\(baseURL)/\(model.rawValue):generateContent?key=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            throw GeminiClientError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiClientError.emptyResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode(GeminiResponse.self, from: data))?.error?.message 
                ?? String(data: data, encoding: .utf8) 
                ?? "HTTP \(httpResponse.statusCode)"
            throw GeminiClientError.badResponse(statusCode: httpResponse.statusCode, message: errorMsg)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let resultText = geminiResponse.firstText, !resultText.isEmpty else {
            throw GeminiClientError.emptyResponse
        }
        
        return resultText
    }
    
    // MARK: - Multimodal (Images, Audio Voice Notes, Documents)
    
    public func analyzeMedia(
        prompt: String,
        mediaData: Data,
        mimeType: String,
        model: GeminiModel = .flash20
    ) async throws -> String {
        guard let apiKey = GeminiKeychain.load(), !apiKey.isEmpty else {
            throw GeminiClientError.missingApiKey
        }
        
        let contents = [
            GeminiContent(parts: [
                GeminiPart(mimeType: mimeType, data: mediaData),
                GeminiPart(text: prompt)
            ])
        ]
        
        let requestBody = GeminiRequest(contents: contents)
        let endpoint = "\(baseURL)/\(model.rawValue):generateContent?key=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            throw GeminiClientError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiClientError.emptyResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode(GeminiResponse.self, from: data))?.error?.message 
                ?? String(data: data, encoding: .utf8) 
                ?? "HTTP \(httpResponse.statusCode)"
            throw GeminiClientError.badResponse(statusCode: httpResponse.statusCode, message: errorMsg)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = geminiResponse.firstText else {
            throw GeminiClientError.emptyResponse
        }
        return text
    }
}
