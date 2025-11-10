import SwiftUI
import SwiftData

#if canImport(FoundationModels)
import FoundationModels
#endif

struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var person: Person

    @State private var budget: BudgetBand = .medium
    @State private var giftPref: GiftTypePreference = .balanced
    @State private var toneHint: String = ""
    @State private var ideas: [GiftIdea] = []
    @State private var cardMessage: String = ""
    @State private var isLoadingIdeas = false
    @State private var isLoadingCard = false

#if canImport(FoundationModels)
    @State private var modelAvailability: SystemLanguageModel.Availability = .unavailable(.modelNotReady)
#else
    @State private var modelAvailabilityMessage: String = "Apple Intelligence not available on this device"
#endif

    private let ai = FoundationAIService()

    var body: some View {
        Form {
            Section {
                TextEditor(text: $person.notes)
                    .frame(minHeight: 140)
            } header: {
                Text("Profile notes")
            }

            Section {
                TextField(
                    "Occasion (e.g., Birthday, Christmas)",
                    text: Binding<String>(
                        get: { person.upcomingOccasion ?? "" },
                        set: { person.upcomingOccasion = $0.isEmpty ? nil : $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)

                TextField("Tone hint (optional)", text: $toneHint)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("Occasion")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget")
                        .font(.subheadline.weight(.semibold))
                    Picker("Budget", selection: $budget) {
                        ForEach(BudgetBand.allCases) { b in
                            Text(b.rawValue.capitalized).tag(b)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityHint("Choose a price range for gift ideas: low, medium, or high.")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Gift preference")
                        .font(.subheadline.weight(.semibold))
                    Picker("Gift preference", selection: $giftPref) {
                        ForEach(GiftTypePreference.allCases) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityHint("Choose whether you prefer tangible items or experience-based gifts.")
                }
            } header: {
                Text("Preferences")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Low = inexpensive • Medium = moderate • High = premium")
                    Text("Physical = tangible items • Experience = activities/events • Balanced = either")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Section {
                availabilityView
            }

            if !ideas.isEmpty {
                Section {
                    ForEach(ideas) { idea in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(idea.ideaTitle)
                                    .font(.headline)
                                Spacer()
                                Text(idea.priceBand.display)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: Capsule())
                            }
                            Text(idea.description)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Gift Ideas")
                }
            }

            if !cardMessage.isEmpty {
                Section {
                    Text(cardMessage)
                        .textSelection(.enabled)
                        .padding(8)
                } header: {
                    Text("Card Message")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text(person.name))
        .onAppear {
#if canImport(FoundationModels)
            modelAvailability = FoundationAIService().checkAvailability()
#endif
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    Task { await generateIdeas() }
                } label: {
                    Label("Generate Ideas", systemImage: isLoadingIdeas ? "hourglass" : "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Generate a short list of tailored gift ideas.")
                .disabled(isLoadingIdeas || isUnavailable)

                Button {
                    Task { await generateCard() }
                } label: {
                    Label("Card Message", systemImage: isLoadingCard ? "hourglass" : "heart.text.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Generate a concise card message based on the notes and occasion.")
                .disabled(isLoadingCard || isUnavailable)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .shadow(radius: 1)
        }
        .animation(.snappy, value: ideas)
        .animation(.snappy, value: cardMessage)
    }

    private var isUnavailable: Bool {
#if canImport(FoundationModels)
        switch modelAvailability {
        case .available: return false
        default: return true
        }
#else
        return true
#endif
    }

    @ViewBuilder
    private var availabilityView: some View {
#if canImport(FoundationModels)
        switch modelAvailability {
        case .available:
            EmptyView()
        case .unavailable(.deviceNotEligible):
            callout("Device not eligible for Apple Intelligence", systemImage: "exclamationmark.triangle", tint: .orange)
        case .unavailable(.appleIntelligenceNotEnabled):
            callout("Enable Apple Intelligence in Settings to generate ideas", systemImage: "gear", tint: .yellow)
        case .unavailable(.modelNotReady):
            callout("Model is preparing or downloading...", systemImage: "arrow.down.circle", tint: .blue)
        case .unavailable(let other):
            callout("Model unavailable: \(String(describing: other))", systemImage: "questionmark.circle", tint: .gray)
        }
#else
        callout("Apple Intelligence not available on this device", systemImage: "bolt.slash", tint: .gray)
#endif
    }

    @ViewBuilder
    private func callout(_ text: String, systemImage: String, tint: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func generateIdeas() async {
        isLoadingIdeas = true
        defer { isLoadingIdeas = false }
#if canImport(FoundationModels)
        do {
            let result = try await ai.generateIdeas(
                for: person.name,
                notes: person.notes,
                occasion: person.upcomingOccasion,
                budget: budget,
                giftPreference: giftPref
            )
            await MainActor.run { ideas = result }
        } catch {
            await MainActor.run { ideas = [] }
            print("Failed to generate ideas: \(error)")
        }
#else
        await MainActor.run { ideas = [] }
#endif
    }

    private func generateCard() async {
        isLoadingCard = true
        defer { isLoadingCard = false }
#if canImport(FoundationModels)
        do {
            let text = try await ai.generateCardMessage(
                for: person.name,
                notes: person.notes,
                occasion: person.upcomingOccasion,
                toneHint: toneHint
            )
            await MainActor.run { cardMessage = text }
        } catch {
            await MainActor.run { cardMessage = "" }
            print("Failed to generate card: \(error)")
        }
#else
        await MainActor.run { cardMessage = "" }
#endif
    }
}

