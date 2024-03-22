import SwiftUI

//struct ParentPickerView: View {
//    let onSelect: (Item) -> Void
//    @Environment(\.dismiss) var dismiss
//    @State private var items: [Item] = []
//    var body: some View {
//        List {
//            ForEach(items) { item in
//                let disabled = !storage.isParentSelected(parentId: item.id)
//                Button(item.name) {
//                    onSelect(item)
//                    dismiss()
//                }
//                .foregroundStyle(disabled ? .secondary : .primary)
//                .disabled(disabled)
//            }
//        }
//        .task {
//            self.items = await storage.parents()
//        }
//    }
//}

//struct ChildPickerView: View {
//    let parentId: String
//    let onSelect: (Item) -> Void
//    @Environment(\.dismiss) var dismiss
//    @State private var items: [Item] = []
//    var body: some View {
//        List {
//            ForEach(items) { item in
//                Button(item.name) {
//                    onSelect(item)
//                    dismiss()
//                }.foregroundStyle(.primary)
//            }
//        }
//        .task {
//            items = await storage.childs(parentId: parentId)
//        }
//    }
//}

struct SubListsDemo: View {
    @State private var items: [Item] = []

    var body: some View {
        List {
            ForEach(items.indices, id: \.self) { parentIndex in
                let parent = items[parentIndex]
                Section(parent.name) {
                    ForEach(parent.items.indices, id: \.self) { childIndex in
                        let child = items[parentIndex].items[childIndex]
                        NavigationLink {
                            Text("Child picker")
//                            ChildPickerView(id: self.storage.items[parentIndex].id) { selected in
//                                self.items[parentIndex].items.append(selected)
//                            }
                        } label: {
                            Text(child.name)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            //self.storage.removeChild(parentId: parent.id, childId: parent.items[index].id)
                        }
                    })
                    
                    NavigationLink {
                        Text("child picker")
                    } label: {
                        Text("Add").foregroundStyle(.secondary)
                    }
                    .deleteDisabled(!parent.items.isEmpty)
                    .moveDisabled(true)
                }
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let parent = items[index]
                    if parent.items.isEmpty {
                        print("removing parent '\(parent.name)'")
                        items.remove(at: index)
                    } else {
                        print("ignoring not empty '\(parent.name)'")
                    }
                }
            })
        }
        .navigationTitle("Example")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !items.isEmpty {
                NavigationLink {
                    Text("parent picker")
//                    ParentPickerView(storage: storage) { selected in
//                        Task { await self.storage.addParent(item: selected) }
//                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView {
                    Label("Empty", systemImage: "tray.fill")
                } description: {
                    Text("List is empty")
                    NavigationLink {
                        Text("parent picker")
//                        ParentPickerView(storage: storage) { selected in
//                            Task { await self.storage.addParent(item: selected) }
//                        }
                    } label: {
                        Text("Add")
                    }
                }
            }
        }
        .task {
            items = sample
        }
        .refreshable {
            items = sample
        }
    }
    
    private let sample: [Item] = [
        Item("1", "Parent1", [Item("1", "Child1"), Item("2", "Child2")]),
        Item("2", "Parent2")
    ]
}

struct Item: Identifiable, Hashable {
    var id: String
    var name: String
    var items: [Item]
    
    init(_ id: String, _ name: String, _ items: [Item]) {
        self.id = id
        self.name = name
        self.items = items
    }
    
    init(_ id: String, _ name: String) {
        self.init(id, name, [])
    }
}

#Preview {
    NavigationStack {
        SubListsDemo()
    }
}
