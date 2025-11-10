import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var notes: String
    var createdAt: Date
    var upcomingOccasion: String?

    init(name: String, notes: String = "", createdAt: Date = Date(), upcomingOccasion: String? = nil) {
        self.name = name
        self.notes = notes
        self.createdAt = createdAt
        self.upcomingOccasion = upcomingOccasion
    }
}
