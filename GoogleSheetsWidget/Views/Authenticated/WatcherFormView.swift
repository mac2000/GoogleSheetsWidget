import SwiftUI
import SwiftData

struct WatcherFormView: View {
    @Bindable var item: Watcher
    
    var spreadsheets: [String] = ["Demo1", "Demo2", "Demo3"]
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $item.title)
            }
            
            Section("Spreadsheet") {
                Picker("Spreadsheet", selection: $item.spreadsheetId) {
                    Text("Demo1")
                }
            }
        }
        .navigationTitle("Track")
        .navigationBarTitleDisplayMode(.inline)
        
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
            NavigationStack {
                WatcherFormView(item: Watcher.example1)
            }.tabItem {
                Label("Data", systemImage: "doc.text")
            }.tag(1)
            WidgetsView().tabItem {
                Label("Widgets", systemImage: "square.grid.3x2")
            }.tag(2)
            InfoView().tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(3)
        }
        .modelContainer(container)
    } catch {
        fatalError("failed to create model container because of: \(error.localizedDescription)")
    }
}
