import Foundation

struct GiftIdea: Identifiable, Codable, Hashable {
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

    var id: UUID = UUID()
    var ideaTitle: String
    var description: String
    var priceBand: PriceBand
}
