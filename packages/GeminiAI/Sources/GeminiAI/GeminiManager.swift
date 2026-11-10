import Foundation

public final class GeminiManager {
    public static let shared = GeminiManager()
    
    private let kPreferredModelKey = "telemac_gemini_preferred_model"
    private let kCustomModelCodeKey = "telemac_gemini_custom_model_code"
    
    /// User can manually type any custom agent/model code as Google/others launch new models
    public var customModelCode: String? {
        get {
            let val = UserDefaults.standard.string(forKey: kCustomModelCodeKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (val?.isEmpty ?? true) ? nil : val
        }
        set {
            if let newValue = newValue?.trimmingCharacters(in: .whitespacesAndNewlines), !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: kCustomModelCodeKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kCustomModelCodeKey)
            }
        }
    }
    
    /// The active model used for all AI calls: custom typed agent code takes precedence if set, otherwise preset
    public var activeModel: GeminiModel {
        if let custom = customModelCode {
            return GeminiModel(custom)
        }
        return preferredModel
    }
    
    public var preferredModel: GeminiModel {
        get {
            if let saved = UserDefaults.standard.string(forKey: kPreferredModelKey) {
                return GeminiModel(saved)
            }
            return .flash20
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kPreferredModelKey)
        }
    }
    
    public var isConfigured: Bool {
        return GeminiKeychain.hasKey
    }
    
    // MARK: - 1. Summarize Chat
    
    public func summarize(chat: GeminiChatContext, maxMessages: Int = 100) async throws -> String {
        let systemPrompt = """
        You are a concise, high-efficiency assistant inside TeleMac. 
        Your task is to summarize the following chat conversation into:
        1. Key Decisions Made
        2. Important Discussion Points
        3. Pending Action Items (with assignees if mentioned)
        Keep it clean, organized with Markdown bullet points, and avoid fluff.
        """
        
        let userPrompt = "Please summarize this conversation based on the context provided."
        return try await GeminiClient.shared.generate(
            prompt: userPrompt,
            context: chat,
            systemInstruction: systemPrompt,
            model: activeModel,
            temperature: 0.2
        )
    }
    
    // MARK: - 2. Smart Compose & Draft Replies
    
    public func smartCompose(intent: String, chat: GeminiChatContext?) async throws -> String {
        let systemPrompt = """
        You are a smart ghostwriter inside TeleMac. Draft a natural, human message that matches the conversation context and tone.
        Return ONLY the draft message ready to be sent, with no introductory or concluding meta-commentary.
        """
        
        return try await GeminiClient.shared.generate(
            prompt: "Draft a message with this intent: \(intent)",
            context: chat,
            systemInstruction: systemPrompt,
            model: activeModel,
            temperature: 0.7
        )
    }
    
    // MARK: - 3. Rewrite Message
    
    public func rewrite(text: String, style: GeminiFeatureMode.RewriteStyle) async throws -> String {
        let prompt = """
        Rewrite the following message. Goal: \(style.rawValue).
        Return ONLY the rewritten text, without quotes or explanation.
        
        Original message:
        \(text)
        """
        return try await GeminiClient.shared.generate(prompt: prompt, model: activeModel, temperature: 0.3)
    }
    
    // MARK: - 4. Contextual Translation
    
    public func translate(text: String, to targetLanguage: String = "English") async throws -> String {
        let prompt = """
        Translate the following text into natural, idiomatic \(targetLanguage).
        Preserve technical terminology, tone, formatting, and markdown links.
        Return ONLY the translation without preamble.
        
        Text to translate:
        \(text)
        """
        return try await GeminiClient.shared.generate(prompt: prompt, model: activeModel, temperature: 0.1)
    }
    
    // MARK: - 5. Voice Transcription
    
    public func transcribeAudio(audioData: Data, mimeType: String = "audio/ogg") async throws -> String {
        let prompt = """
        Accurately transcribe all spoken words in this audio. 
        Format into readable paragraphs with punctuation.
        If the audio contains code or technical terms, spell them accurately.
        """
        return try await GeminiClient.shared.analyzeMedia(
            prompt: prompt,
            mediaData: audioData,
            mimeType: mimeType,
            model: activeModel
        )
    }
    
    // MARK: - 6. Image & Document Analysis
    
    public func analyzeFile(data: Data, mimeType: String, query: String) async throws -> String {
        let prompt = query.isEmpty ? "Explain this document/image in detail and extract all key data." : query
        return try await GeminiClient.shared.analyzeMedia(
            prompt: prompt,
            mediaData: data,
            mimeType: mimeType,
            model: activeModel
        )
    }
    
    // MARK: - 7. Educational Video Study Notes
    
    public func generateEducationalNotes(title: String, transcriptOrSummary: String) async throws -> String {
        let systemPrompt = """
        You are a top-tier educational tutor assisting a learner using TeleMac.
        Create structured study notes from the following educational video/lecture content:
        
        # 📌 [Title of Video/Topic]
        
        ## 🎯 Overview & Core Objective
        (1-2 paragraphs explaining the big picture)
        
        ## 🧠 Key Takeaways
        - Bullet point breakdown of primary lessons
        
        ## ⏱️ Chapters & Topics Covered
        - Approximate progression and concepts
        
        ## 💡 Practical Examples & Code / Formulas
        - Concrete applications discussed
        
        ## ❓ Review & Self-Check Questions
        - 3-5 thought-provoking questions with brief answers to test retention
        """
        
        let prompt = "Video Title: \(title)\n\nTranscript or Content Details:\n\(transcriptOrSummary)"
        return try await GeminiClient.shared.generate(
            prompt: prompt,
            systemInstruction: systemPrompt,
            model: .pro15, // Use 1.5 Pro for deep educational reasoning
            temperature: 0.2
        )
    }
}
