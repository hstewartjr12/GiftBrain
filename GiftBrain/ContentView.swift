import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedPerson: Person?

    var body: some View {
        NavigationSplitView {
            PeopleListView(selectedPerson: $selectedPerson)
        } detail: {
            if let selectedPerson {
                PersonDetailView(person: selectedPerson)
            } else {
                ContentPlaceholder()
            }
        }
    }
}

private struct ContentPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme

    private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [baseColor, baseColor.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "gift.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Welcome to GiftBrain")
                    .font(.largeTitle.weight(.semibold))
                Text("Select a person to generate thoughtful gift ideas and a card message.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(24)
            .glassEffect(in: .rect(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
