# AGENTS.md

Single-target SwiftUI app (`GiftBrain`) using SwiftData + Apple's FoundationModels framework for on-device gift-idea generation. No external SPM dependencies.

## Build & test

No Makefile/Package.swift; build through `xcodebuild` against `GiftBrain.xcodeproj`:

```sh
# Build (auto SDK picks a platform via SDKROOT=auto; specify destination explicitly)
xcodebuild -project GiftBrain.xcodeproj -scheme GiftBrain \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Tests use Swift Testing (`import Testing`, NOT XCTest). Run via:
xcodebuild -project GiftBrain.xcodeproj -scheme GiftBrain \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Single test:
xcodebuild ... -only-testing:GiftBrainTests/GiftBrainTests/example
```

`GiftBrainTests/GiftBrainTests.swift` is just a stub; the suite currently asserts nothing meaningful.

Targets: `GiftBrain` (app), `GiftBrainTests` (unit), `GiftBrainUITests` (UI). Update `project.pbxproj` to add files — the project is not Package-based.

## Platform matrix gotchas

`SUPPORTED_PLATFORMS = iphoneos iphonesimulator macosx xros xrsimulator`, `TARGETED_DEVICE_FAMILY = 1,2,7` (iPhone/iPad/visionOS), `SDKROOT = auto`. Deployment targets: iOS/macOS 27.0. Building requires Xcode 27; this code will NOT build on older toolchains.

`FoundationAIService` and most of `PersonDetailView` are wrapped in `#if canImport(FoundationModels)` with a stub fallback in `FoundationAIService.swift:142-160`. Any change to those APIs must keep both branches compiling or the non-Apple-Intelligence platform build will break.

## SwiftData schema & migrations

`GiftBrainMigration.swift` declares `GiftBrainSchemaV1`/`V2`/`V3` with a lightweight-only migration plan. V1 has `createdAt` (removed in V2); V2 stores `budgetBandRaw`/`giftPreferenceRaw` as `String`; V3 (the live model in `Person.swift`) uses the iOS 27 `@Attribute(.codable)` storage option with `originalName:` to map V2 raw string columns to `Codable` enum types (`PriceBand`, `GiftTypePreference`).

When adding new `Codable` enum fields, use `@Attribute(.codable, originalName:)` with the raw-string column name from the prior schema version to keep lightweight migration possible. Do not revert to raw `String` with computed accessors — that was the pre-iOS-27 workaround.

`GiftBrainApp.swift` `ModelContainerFactory.make()` deliberately **destroys the store on migration failure** and retries once. This is intentional (dev-recovery), not a bug — don't "fix" it by removing the destroy branch without replacing the recovery behavior. `ContentView` and `PeopleListView` previews use `.modelContainer(for: Person.self, inMemory: true)`, not the shared container.

## FoundationModels usage

Generation happens via `LanguageModelSession` + `@Generable` structs (`GiftIdeaList`, `GiftIdeaEntry`) in `FoundationAIService.swift`. `FoundationAIService` stores a `LanguageModel` instance (`var model: any LanguageModel`) — iOS 27's protocol lets you swap in Claude, Gemini, or PrivateCloudCompute models behind the same session API. `PersonDetailView` gates generation on `isModelAvailable` computed from the AI service's `checkAvailability()`. New AI entry points must also check availability first; calling on `.unavailable` throws.

## Conventions

- Code style: 4-space indent, no trailing comments, `private`/`@State`/@Environment` patterns standard SwiftUI.
- Enum string-backed domain types live alongside consumers (`PriceBand` in `GiftIdea.swift`, `GiftTypePreference` in `FoundationAIService.swift`).
- `.derivedData/` is committed-adjacent (gitignored) — xcodebuild output goes here; do not reference its contents as source.
- Bundle ID `henrystewart.GiftBrain`, dev team `C48CP86U4C`. Don't change team/bundle ID casually — breaks keychain/entitlements.