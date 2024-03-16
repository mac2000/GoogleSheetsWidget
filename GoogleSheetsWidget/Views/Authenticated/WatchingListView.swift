import SwiftUI
import SwiftData
import OSLog

struct WatchingListView: View {
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WatchingListView")
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Watcher.title) var items: [Watcher]
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Tracking") {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            HStack{
                                VStack(alignment:.leading){
                                    Text(item.title)
                                    HStack{
                                        Text("\(item.sheetName ?? "unknown")!\(item.column)\(item.row)")
                                        Text("/")
                                        Text(item.spreadsheetName ?? "unknown")
                                    }.font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                Text(item.value ?? "N/A")
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                
            }
            .toolbar {
                Button("Add", systemImage: "plus", action: add)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No data", systemImage: "doc.text", description: Text("Tap on \"+\" button on top right corner"))
                }
            }
            .refreshable {
                refresh()
            }
            .navigationTitle("Data")
            .navigationDestination(for: Watcher.self) { item in
                WatcherFormView(item: item)
            }
            .onAppear {
                for item in items {
                    if item.isEmpty {
                        modelContext.delete(item)
                    }
                }
            }
        }
    }
    
    func add() {
        let item = Watcher(title: "", spreadsheetId: "", spreadsheetName: "", sheetName: "Sheet1", column: "A", row: 1)
        modelContext.insert(item)
        path.append(item)
    }
    
    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            let item = items[index]
            modelContext.delete(item)
        }
    }
    
    func refresh() {
        for item in items {
            log.info("\(item.title)")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Watcher.self, configurations: config)
        
        container.mainContext.insert(Watcher.example1)
        container.mainContext.insert(Watcher.example2)
        container.mainContext.insert(Watcher.example3)
        
        return TabView(selection: .constant(1)) {
            WatchingListView().tabItem {
                Label("Data", systemImage: "doc.text")
            }.tag(1)
            WidgetsView().tabItem {
                Label("Widgets", systemImage: "square.grid.3x2")
            }.tag(2)
            InfoView().tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(3)
        }
        .environment(Auth())
        .modelContainer(container)
    } catch {
        fatalError("failed to create model container because of: \(error.localizedDescription)")
    }
}
