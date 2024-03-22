import SwiftUI
import OSLog
import Shared

struct SettingsTab: View {
    let log = Logger("InfoView")
    @Environment(Auth.self) var auth
    @State private var message = "Authenticated"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Message") {
                    Text(message)
                }
                Section("Actions") {
                    Button("Logout", action: auth.logout)
                    Button("Refresh", action: renew)
                    Button("Demo", action: demo)
                }
            }
            .navigationBarTitle("Settings")
        }
    }
    
    func demo() {
        Task {
            guard let accessToken = await auth.refresh() else {
                log.info("unable retrieve accessToken")
                return
            }
            let spreadsheets = await GoogleSheets.getSpreadsheets(accessToken, "")
            log.info("spreadsheets: \(spreadsheets.count)")
            message = "\(spreadsheets.count) spreadsheets"
        }
    }
    
    func renew() {
        Task {
            let _ = await auth.refresh()
            log.info("refreshed")
            message = "refreshed"
        }
    }
}

#Preview {
    TabView(selection: .constant(3)) {
        DataTab().tabItem {
            Label("Data", systemImage: "doc.text")
        }.tag(1)
        WidgetsTab().tabItem {
            Label("Widgets", systemImage: "square.grid.3x2")
        }.tag(2)
        SettingsTab().tabItem {
            Label("Settings", systemImage: "gear")
        }.tag(3)
    }
    .environment(Auth())
}
