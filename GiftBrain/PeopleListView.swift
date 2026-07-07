import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    @Binding var selectedPerson: Person?

    @State private var isPresentingAdd = false

    var body: some View {
        List(selection: $selectedPerson) {
            ForEach(people) { person in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Text(String(person.name.prefix(1)).uppercased())
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tint)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.headline)
                        if !person.notes.isEmpty {
                            Text(person.notes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .tag(person)
            }
            .onDelete(perform: deletePeople)
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .navigationTitle("People")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarLeading) { EditButton() }
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            NavigationStack {
                AddPersonView { name, notes in
                    let person = Person(name: name, notes: notes)
                    modelContext.insert(person)
                    selectedPerson = person
                    isPresentingAdd = false
                } onCancel: {
                    isPresentingAdd = false
                }
            }
        }
    }

    private func deletePeople(at offsets: IndexSet) {
        for index in offsets {
            let person = people[index]
            if selectedPerson?.persistentModelID == person.persistentModelID {
                selectedPerson = nil
            }
            modelContext.delete(person)
        }
    }
}

#Preview {
    @Previewable @State var selectedPerson: Person?
    NavigationSplitView {
        PeopleListView(selectedPerson: $selectedPerson)
    } detail: {
        Text("Select a person")
    }
    .modelContainer(for: Person.self, inMemory: true)
}
