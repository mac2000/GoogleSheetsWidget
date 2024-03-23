import SwiftUI
import SwiftData
import Shared

struct SpreadsheetPicker: View {
    var onSelect: (Spreadsheet) -> Void
    @State var loading = false
    @Environment(\.dismiss) var dismiss
    @Environment(Auth.self) var auth
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Watcher.title) var items: [Watcher]
    @StateObject private var search = DebouncedState(initialValue: "")
    @State private var retrieved: [Spreadsheet] = []
    
    var recent: [Spreadsheet] {
        var set = Set<Spreadsheet>()
        for item in items {
            if let spreadsheetId = item.spreadsheetId,
               let spreadsheetName = item.spreadsheetName {
                set.insert(Spreadsheet(id: spreadsheetId, name: spreadsheetName))
            }
        }
        return Array(set).sorted { $0.name < $1.name }
    }
    
    var filteredRecent: [Spreadsheet] {
        if search.debouncedValue.isEmpty {
            return recent
        } else {
            return recent.filter { $0.name.localizedStandardContains(search.debouncedValue) }
        }
    }
    
    var body: some View {
        List {
            if !recent.isEmpty && search.debouncedValue.isEmpty {
                Section("Recent") {
                    ForEach(recent) { item in
                        row(item)
                    }
                }
            }
            Section("Spreadsheets") {
                ForEach(retrieved) { item in
                    row(item)
                }
            }
        }
        .overlay {
            if loading {
                ContentUnavailableView("Loading", systemImage: "arrow.down.circle.dotted", description: Text("Retrieving items list"))
            }
            else if items.isEmpty {
                ContentUnavailableView("Empty", systemImage: "doc.text.magnifyingglass", description: Text("Empty list retrieved"))
            }
        }
        .searchable(text: $search.currentValue)
        .task { await load() }
        .refreshable { await load() }
        .onChange(of: search.debouncedValue, { _, _ in
            Task { await load() }
        })
        .navigationTitle("Spreadsheets")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func row(_ item: Spreadsheet) -> some View {
        return Button(item.name) {
            self.onSelect(item)
            dismiss()
        }.foregroundStyle(.primary)
    }
    
    func load() async {
        loading = true
        defer { loading = false }
        // item = nil
        // pretend we are retrieving list from backend
        let sleepSeconds = 1
        try? await Task.sleep(nanoseconds: UInt64(sleepSeconds) * NSEC_PER_SEC)
        var items = (1...20).map { num in
            let name = "Item \(num)"
            return Spreadsheet(id: "\(num)", name: name)
        }
        
        if search.debouncedValue != "" {
            items = items.filter { $0.name.localizedStandardContains(search.debouncedValue) }
        }
        
        self.retrieved = items
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Watcher.self, configurations: config)
        
        container.mainContext.insert(Watcher.example1)
        container.mainContext.insert(Watcher.example2)
        container.mainContext.insert(Watcher.example3)
        
        return NavigationStack {
            SpreadsheetPicker() { item in
                print("selected", item.name)
            }
        }
        .environment(Auth())
        .modelContainer(container)
    } catch {
        fatalError("failed to create model container because of: \(error.localizedDescription)")
    }
}
