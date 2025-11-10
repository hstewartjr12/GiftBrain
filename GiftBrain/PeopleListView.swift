import SwiftUI
import SwiftData

struct PeopleListView: View {
    // Provide expected data and environment dependencies
    @Environment(\.modelContext) private var modelContext

    // Assuming `people` is provided from SwiftData; adjust the predicate/sort as needed
    @Query(sort: \Person.name) private var people: [Person]

    @State private var isPresentingAdd = false

    var body: some View {
        List {
            ForEach(people) { person in
                NavigationLink {
                    PersonDetailView(person: person)
                } label: {
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
                }
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
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $isPresentingAdd) {
            NavigationStack {
                AddPersonView { name, notes in
                    let p = Person(name: name, notes: notes)
                    modelContext.insert(p)
                    isPresentingAdd = false
                } onCancel: {
                    isPresentingAdd = false
                }
            }
        }
    }

    private func deletePeople(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(people[index]) }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        PeopleListView()
    }
}
