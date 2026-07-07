import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var notes: String
    var upcomingOccasion: String?
    @Attribute(.codable, originalName: "budgetBandRaw") var budget: PriceBand = PriceBand.medium
    @Attribute(.codable, originalName: "giftPreferenceRaw") var giftPreference: GiftTypePreference = GiftTypePreference.balanced
    var toneHint: String = ""

    init(
        name: String,
        notes: String = "",
        upcomingOccasion: String? = nil,
        budget: PriceBand = PriceBand.medium,
        giftPreference: GiftTypePreference = GiftTypePreference.balanced,
        toneHint: String = ""
    ) {
        self.name = name
        self.notes = notes
        self.upcomingOccasion = upcomingOccasion
        self.budget = budget
        self.giftPreference = giftPreference
        self.toneHint = toneHint
    }
}
