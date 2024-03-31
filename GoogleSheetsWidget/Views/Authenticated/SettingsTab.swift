import SwiftUI
import SwiftData
import OSLog
import Shared

struct SettingsTab: View {
    let log = Logger("InfoView")
    @Environment(Auth.self) var auth
    @State private var message = "Authenticated"
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Watcher.title) var items: [Watcher]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Message") {
                    Text(message)
                }
                Section("Actions") {
                    Button("Logout", action: auth.logout)
                    Button("Refresh") {
                        Task {
                            let _ = await self.auth.refresh()
                            log.info("Refreshed")
                            self.message = "Refreshed"
                        }
                    }
                    Button("Test") {
                        Task {
                            for item in items {
                                modelContext.delete(item)
                            }
                            guard let accessToken = await auth.refresh() else {
                                log.info("unable retrieve accessToken")
                                return
                            }
                            let spreadsheets = await GoogleSheets.getSpreadsheets(accessToken, "")
                            log.info("spreadsheets: \(spreadsheets.count)")
                            message = "Retrieved \(spreadsheets.count) spreadsheets"
                        }
                    }
                    Button("Reset") {
                        Task {
                            for item in items {
                                modelContext.delete(item)
                            }
                            log.info("Deleted")
                            message = "Deleted"
                        }
                    }
                }
                
                Section("Common") {
                    Link("Submit issue", destination: URL(string: "https://github.com/mac2000/GoogleSheetsWidget/issues/new")!)
                }
            }
            .navigationBarTitle("Settings")
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
        
        return TabView(selection: .constant(2)) {
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
