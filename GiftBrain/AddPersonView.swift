import SwiftUI

struct AddPersonView: View {
    var onSave: (String, String) -> Void
    var onCancel: () -> Void

    @State private var name = ""
    @State private var notes = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Full name", text: $name)
                    .textContentType(.name)
            }
            Section("Profile notes") {
                ProfileNotesEditor(text: $notes, minHeight: 120)
            }
        }
        .navigationTitle("New Person")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(
                        trimmedName,
                        notes.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
                .disabled(trimmedName.isEmpty)
            }
        }
    }
}
