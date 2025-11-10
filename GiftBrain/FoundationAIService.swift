import Foundation
#if canImport(FoundationModels)
import FoundationModels

@Generable(description: "A short list of tailored gift ideas for a specific person")
struct GiftIdeaList {
    @Guide(description: "Between 3 and 5 ideas", .count(3...5))
    var ideas: [GiftIdeaEntry]
}

@Generable(description: "One gift idea")
struct GiftIdeaEntry: Codable {
    @Guide(description: "Short, punchy title for the gift idea (max 6 words)")
    var ideaTitle: String

    @Guide(description: "1–2 sentences explaining why this fits the person")
    var description: String

    // Use a string field and map manually to our UI model
    @Guide(description: "One of: low, medium, high")
    var priceBand: String
}

enum BudgetBand: String, Codable, CaseIterable, Identifiable { case low, medium, high; var id: Self { self } }
enum GiftTypePreference: String, Codable, CaseIterable, Identifiable { case physical, experience, balanced; var id: Self { self } }

struct FoundationAIService {
    private let baseInstructions = """
    You are Gift Brain, a concise gift-concept generator.
    - Respect the user's notes and preferences.
    - Avoid clutter gifts if the person dislikes clutter.
    - Don't output shopping links or brands; focus on concepts.
    - Keep ideas realistic to the budget band.
    - Be kind and human.
    """

    func checkAvailability() -> SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    func generateIdeas(for personName: String, notes: String, occasion: String?, budget: BudgetBand, giftPreference: GiftTypePreference, temperature: Double = 0.8) async throws -> [GiftIdea] {
        let session = LanguageModelSession(instructions: baseInstructions)
        let prompt = """
        Person: \(personName)
        Occasion: \(occasion ?? "none specified")
        Profile notes: \(notes)
        Budget band: \(budget.rawValue)
        Preference: \(giftPreference.rawValue) (physical vs experience)
        Task: Propose 3–5 concrete gift concepts. Keep each description to 1–2 sentences.
        """
        let options = GenerationOptions(temperature: temperature)
        let response = try await session.respond(to: prompt, generating: GiftIdeaList.self, options: options)
        return response.content.ideas.map { entry in
            GiftIdea(ideaTitle: entry.ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                     description: entry.description.trimmingCharacters(in: .whitespacesAndNewlines),
                     priceBand: GiftIdea.PriceBand(rawValue: entry.priceBand) ?? .medium)
        }
    }

    func generateCardMessage(for personName: String, notes: String, occasion: String?, toneHint: String? = nil, temperature: Double = 0.6) async throws -> String {
        let session = LanguageModelSession(instructions: "You are a thoughtful card-writing assistant. Keep messages warm, sincere, and concise (1–2 sentences). Avoid emojis. Keep it in the user's voice but a touch warmer.")
        var prompt = """
        Person: \(personName)
        Occasion: \(occasion ?? "none specified")
        Bullet-style notes: \(notes)
        Task: Write a short card message (1–2 sentences). No quotes around the message.
        """
        if let toneHint, !toneHint.isEmpty { prompt += "\nTone hint: \(toneHint)" }
        let options = GenerationOptions(temperature: temperature)
        let response = try await session.respond(to: prompt, options: options)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#else

enum BudgetBand: String, Codable, CaseIterable, Identifiable { case low, medium, high; var id: Self { self } }
enum GiftTypePreference: String, Codable, CaseIterable, Identifiable { case physical, experience, balanced; var id: Self { self } }

struct FoundationAIService {
    func checkAvailability() -> String { "Unavailable" }
    func generateIdeas(for personName: String, notes: String, occasion: String?, budget: BudgetBand, giftPreference: GiftTypePreference, temperature: Double = 0.8) async throws -> [GiftIdea] { [] }
    func generateCardMessage(for personName: String, notes: String, occasion: String?, toneHint: String? = nil, temperature: Double = 0.6) async throws -> String { "" }
}

#endif
