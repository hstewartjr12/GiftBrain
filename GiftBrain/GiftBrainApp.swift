import SwiftUI
import SwiftData

@main
struct GiftBrainApp: App {
    var sharedModelContainer: ModelContainer = ModelContainerFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private enum ModelContainerFactory {
    static func make() -> ModelContainer {
        let configuration = ModelConfiguration(
            "GiftBrain",
            schema: Schema([Person.self]),
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: Person.self,
                migrationPlan: GiftBrainMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            // Store was created before schema v2; if lightweight migration fails, reset once.
            destroyStore(at: configuration.url)
            do {
                return try ModelContainer(
                    for: Person.self,
                    migrationPlan: GiftBrainMigrationPlan.self,
                    configurations: configuration
                )
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    private static func destroyStore(at url: URL) {
        let fileManager = FileManager.default
        let relatedURLs = [
            url,
            URL(fileURLWithPath: url.path + "-shm"),
            URL(fileURLWithPath: url.path + "-wal")
        ]
        for fileURL in relatedURLs where fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }
}
