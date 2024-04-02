import SwiftUI
import SwiftData
import Shared
import OSLog
import WidgetKit

struct DataTab: View {
    let log = Logger("WatchingListView")
    @Environment(Auth.self) var auth
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Watcher.title) var items: [Watcher]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tracking") {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            CellView(item: item)
                        }
                    }
                    .onDelete(perform: delete)
                }
                
            }
            .toolbar {
                NavigationLink(value: Watcher(title: "", spreadsheetId: "", spreadsheetName: "", sheetName: "", column: "", row: 1)) {
                    Text("Add")
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No data", systemImage: "doc.text", description: Text("Tap on \"+\" button on top right corner"))
                }
            }
            .task {
                await self.refresh()
            }
            .refreshable {
                await self.refresh()
            }
            .navigationTitle("Data")
            .navigationDestination(for: Watcher.self) { item in
                WatcherFormView(item: item) { item in
                    if item.modelContext == nil && !item.isEmpty {
                        modelContext.insert(item) // technically only this needed
                        print("\(item.title) - created")
                    } else if item.modelContext != nil && !item.isEmpty {
                        print("\(item.title) - edited")
                    } else if item.modelContext != nil && item.isEmpty {
                        modelContext.delete(item)
                        print("\(item.title) - deleted empty item")
                    }
                }
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            let item = items[index]
            modelContext.delete(item)
        }
    }
    
    @MainActor
    func refresh() async {
        guard let accessToken = await auth.refresh() else { return }
        for item in items {
            if item.spreadsheetId == "" || item.sheetName == "" {
                log.info("skipping \(item.title)")
                continue
            }
            log.info("refreshed \(item.sheetName)!\(item.column)\(item.row): \(item.title) - \(item.value)")
            let value = await GoogleSheets.getValue(accessToken, item.spreadsheetId, item.sheetName, item.column, item.row)
            
            item.setValue(value: value)
        }
        WidgetCenter.shared.reloadAllTimelines()
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
            DataTab().tabItem {
                Label("Data", systemImage: "doc.text")
            }.tag(1)
            SettingsTab().tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(2)
        }
        .environment(Auth.shared)
        .modelContainer(container)
    } catch {
        fatalError("failed to create model container because of: \(error.localizedDescription)")
    }
}
