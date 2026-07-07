import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

struct PersonDetailView: View {
    @Bindable var person: Person

    @State private var ideas: [GiftIdea] = []
    @State private var cardMessage = ""
    @State private var isLoadingIdeas = false
    @State private var isLoadingCard = false
    @State private var showError = false
    @State private var errorMessage = ""

#if canImport(FoundationModels)
    @State private var modelAvailability: SystemLanguageModel.Availability = .unavailable(.modelNotReady)
#endif

    private let ai = FoundationAIService()

    private var isAIBusy: Bool { isLoadingIdeas || isLoadingCard }

    var body: some View {
        Form {
            Section {
                ProfileNotesEditor(text: $person.notes, minHeight: 140)
            } header: {
                Text("Profile notes")
            }

            Section {
                TextField(
                    "Occasion (e.g., Birthday, Christmas)",
                    text: Binding(
                        get: { person.upcomingOccasion ?? "" },
                        set: { person.upcomingOccasion = $0.isEmpty ? nil : $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)

                TextField("Tone hint (optional)", text: $person.toneHint)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("Occasion")
            }

            Section {
                Picker("Budget", selection: $person.budget) {
                    ForEach(PriceBand.allCases) { band in
                        Text(band.rawValue.capitalized).tag(band)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityHint("Choose a price range for gift ideas: low, medium, or high.")

                Picker("Gift preference", selection: $person.giftPreference) {
                    ForEach(GiftTypePreference.allCases) { preference in
                        Text(preference.rawValue.capitalized).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityHint("Choose whether you prefer tangible items or experience-based gifts.")
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

            if !isModelAvailable {
                Section { availabilityView }
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
        .navigationTitle(person.name)
        .onAppear {
#if canImport(FoundationModels)
            modelAvailability = ai.checkAvailability()
#endif
        }
        .alert("Couldn't Generate", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    guard !isAIBusy else { return }
                    isLoadingIdeas = true
                    Task { await generateIdeas() }
                } label: {
                    Label("Generate Ideas", systemImage: isLoadingIdeas ? "hourglass" : "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Generate a short list of tailored gift ideas.")
                .disabled(isAIBusy || !isModelAvailable)

                Button {
                    guard !isAIBusy else { return }
                    isLoadingCard = true
                    Task { await generateCard() }
                } label: {
                    Label("Card Message", systemImage: isLoadingCard ? "hourglass" : "heart.text.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Generate a concise card message based on the notes and occasion.")
                .disabled(isAIBusy || !isModelAvailable)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .shadow(radius: 1)
        }
    }

    private var isModelAvailable: Bool {
#if canImport(FoundationModels)
        if case .available = modelAvailability { return true }
        return false
#else
        return false
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

    private func callout(_ text: String, systemImage: String, tint: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func reportError(_ error: Error, context: String) {
        errorMessage = "\(context): \(error.localizedDescription)"
        showError = true
    }

    @MainActor
    private func generateIdeas() async {
        defer { isLoadingIdeas = false }
#if canImport(FoundationModels)
        do {
            ideas = try await ai.generateIdeas(
                for: person.name,
                notes: person.notes,
                occasion: person.upcomingOccasion,
                budget: person.budget,
                giftPreference: person.giftPreference
            )
        } catch {
            reportError(error, context: "Gift ideas failed")
        }
#else
        ideas = []
#endif
    }

    @MainActor
    private func generateCard() async {
        defer { isLoadingCard = false }
#if canImport(FoundationModels)
        do {
            cardMessage = try await ai.generateCardMessage(
                for: person.name,
                notes: person.notes,
                occasion: person.upcomingOccasion,
                toneHint: person.toneHint
            )
        } catch {
            reportError(error, context: "Card message failed")
        }
#else
        cardMessage = ""
#endif
    }
}
