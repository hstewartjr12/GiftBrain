import Foundation
import SwiftData

enum GiftBrainSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Person.self]
    }

    @Model
    final class Person {
        var name: String
        var notes: String
        var createdAt: Date
        var upcomingOccasion: String?

        init(
            name: String,
            notes: String = "",
            createdAt: Date = Date(),
            upcomingOccasion: String? = nil
        ) {
            self.name = name
            self.notes = notes
            self.createdAt = createdAt
            self.upcomingOccasion = upcomingOccasion
        }
    }
}

enum GiftBrainSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Person.self]
    }

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
    }
}

enum GiftBrainSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Person.self]
    }
}

enum GiftBrainMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GiftBrainSchemaV1.self, GiftBrainSchemaV2.self, GiftBrainSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            MigrationStage.lightweight(fromVersion: GiftBrainSchemaV1.self, toVersion: GiftBrainSchemaV2.self),
            MigrationStage.lightweight(fromVersion: GiftBrainSchemaV2.self, toVersion: GiftBrainSchemaV3.self)
        ]
    }
}
