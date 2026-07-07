import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var notes: String
    var upcomingOccasion: String?
    var budgetBandRaw: String = PriceBand.medium.rawValue
    var giftPreferenceRaw: String = GiftTypePreference.balanced.rawValue
    var toneHint: String = ""

    init(
        name: String,
        notes: String = "",
        upcomingOccasion: String? = nil,
        budgetBandRaw: String = PriceBand.medium.rawValue,
        giftPreferenceRaw: String = GiftTypePreference.balanced.rawValue,
        toneHint: String = ""
    ) {
        self.name = name
        self.notes = notes
        self.upcomingOccasion = upcomingOccasion
        self.budgetBandRaw = budgetBandRaw
        self.giftPreferenceRaw = giftPreferenceRaw
        self.toneHint = toneHint
    }

    var budget: PriceBand {
        get { PriceBand(rawValue: budgetBandRaw) ?? .medium }
        set { budgetBandRaw = newValue.rawValue }
    }

    var giftPreference: GiftTypePreference {
        get { GiftTypePreference(rawValue: giftPreferenceRaw) ?? .balanced }
        set { giftPreferenceRaw = newValue.rawValue }
    }
}
