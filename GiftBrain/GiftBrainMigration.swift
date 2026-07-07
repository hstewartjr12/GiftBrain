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
}

enum GiftBrainMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GiftBrainSchemaV1.self, GiftBrainSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [MigrationStage.lightweight(fromVersion: GiftBrainSchemaV1.self, toVersion: GiftBrainSchemaV2.self)]
    }
}
