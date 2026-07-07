import Foundation

enum PriceBand: String, Codable, CaseIterable, Identifiable {
    case low, medium, high
    var id: Self { self }
    var display: String {
        switch self {
        case .low: return "$"
        case .medium: return "$$"
        case .high: return "$$$"
        }
    }
}

struct GiftIdea: Identifiable {
    var id = UUID()
    var ideaTitle: String
    var description: String
    var priceBand: PriceBand
}
