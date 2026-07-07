import Foundation

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

enum GiftTypePreference: String, Codable, CaseIterable, Identifiable {
    case physical, experience, balanced
    var id: Self { self }
}

#if canImport(FoundationModels)
import FoundationModels

@Generable(description: "A short list of tailored gift ideas for a specific person")
struct GiftIdeaList {
    @Guide(description: "Between 3 and 5 ideas", .count(3...5))
    var ideas: [GiftIdeaEntry]
}

@Generable(description: "One gift idea")
struct GiftIdeaEntry {
    @Guide(description: "Short, punchy title for the gift idea (max 6 words)")
    var ideaTitle: String

    @Guide(description: "1–2 sentences explaining why this fits the person")
    var description: String

    @Guide(description: "One of: low, medium, high")
    var priceBand: String
}

struct FoundationAIService {
    private let baseInstructions = """
    You are Gift Brain, a concise gift-concept generator.
    - Respect the user's notes and preferences.
    - Avoid clutter gifts if the person dislikes clutter.
    - Don't output shopping links or brands; focus on concepts.
    - Keep ideas realistic to the budget band.
    - Be kind and human.
    """

    var model: any LanguageModel = SystemLanguageModel()

    func checkAvailability() -> SystemLanguageModel.Availability {
        if let systemModel = model as? SystemLanguageModel {
            return systemModel.availability
        }
        return .unavailable(.modelNotReady)
    }

    func generateIdeas(
        for personName: String,
        notes: String,
        occasion: String?,
        budget: PriceBand,
        giftPreference: GiftTypePreference,
        photo: PlatformImage? = nil
    ) async throws -> [GiftIdea] {
        let session = LanguageModelSession(model: model, instructions: baseInstructions)
        let context = personContext(name: personName, notes: notes, occasion: occasion)
        let options = GenerationOptions(temperature: 0.8)

        let response: LanguageModelSession.Response<GiftIdeaList>
        #if os(iOS)
        if let photo, let cgImage = PlatformImageHelper.cgImage(from: photo) {
            let attachment = Attachment(cgImage)
            response = try await session.respond(generating: GiftIdeaList.self, options: options) {
                context
                """
                Budget band: \(budget.rawValue)
                Preference: \(giftPreference.rawValue) (physical vs experience)
                Task: Propose 3–5 concrete gift concepts. Keep each description to 1–2 sentences.
                Also consider the attached photo of the person or their interests.
                """
                attachment
            }
        } else {
            response = try await session.respond(to: context + """

            Budget band: \(budget.rawValue)
            Preference: \(giftPreference.rawValue) (physical vs experience)
            Task: Propose 3–5 concrete gift concepts. Keep each description to 1–2 sentences.
            """, generating: GiftIdeaList.self, options: options)
        }
        #else
        response = try await session.respond(to: context + """

        Budget band: \(budget.rawValue)
        Preference: \(giftPreference.rawValue) (physical vs experience)
        Task: Propose 3–5 concrete gift concepts. Keep each description to 1–2 sentences.
        """, generating: GiftIdeaList.self, options: options)
        #endif

        return response.content.ideas.map { entry in
            GiftIdea(
                ideaTitle: entry.ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                description: entry.description.trimmingCharacters(in: .whitespacesAndNewlines),
                priceBand: PriceBand(rawValue: entry.priceBand) ?? .medium
            )
        }
    }

    func generateCardMessage(
        for personName: String,
        notes: String,
        occasion: String?,
        toneHint: String? = nil
    ) async throws -> String {
        let session = LanguageModelSession(
            model: model,
            instructions: "You are a thoughtful card-writing assistant. Keep messages warm, sincere, and concise (1–2 sentences). Avoid emojis. Keep it in the user's voice but a touch warmer."
        )
        var prompt = personContext(name: personName, notes: notes, occasion: occasion) + """

        Task: Write a short card message (1–2 sentences). No quotes around the message.
        """
        if let toneHint, !toneHint.isEmpty { prompt += "\nTone hint: \(toneHint)" }
        let options = GenerationOptions(temperature: 0.6)
        let response = try await session.respond(to: prompt, options: options)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func personContext(name: String, notes: String, occasion: String?) -> String {
        """
        Person: \(name)
        Occasion: \(occasion ?? "none specified")
        Profile notes: \(notes)
        """
    }
}

#if os(iOS)
enum PlatformImageHelper {
    static func cgImage(from image: PlatformImage) -> CGImage? {
        return image.cgImage
    }
}
#endif

#else

struct FoundationAIService {
    func checkAvailability() -> String { "Unavailable" }
    func generateIdeas(
        for personName: String,
        notes: String,
        occasion: String?,
        budget: PriceBand,
        giftPreference: GiftTypePreference,
        photo: Any? = nil
    ) async throws -> [GiftIdea] { [] }
    func generateCardMessage(
        for personName: String,
        notes: String,
        occasion: String?,
        toneHint: String? = nil
    ) async throws -> String { "" }
}

#endif
