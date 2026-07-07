import SwiftUI

struct ProfileNotesEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 120

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: minHeight)
    }
}
