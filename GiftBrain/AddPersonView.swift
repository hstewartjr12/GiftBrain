import SwiftUI

struct AddPersonView: View {
    var onSave: (String, String) -> Void
    var onCancel: () -> Void

    @State private var name: String = ""
    @State private var notes: String = ""

    var body: some View {
        Form {
            Section("Name") {
                TextField("Full name", text: $name)
                    .textContentType(.name)
            }
            Section("Profile notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle("New Person")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(name.trimmingCharacters(in: .whitespacesAndNewlines),
                           notes.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
