import SwiftUI
import Shared

struct WidgetsTab: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Settings") {
                    Text("TODO")
                }
            }
            .navigationTitle("Widgets")
        }
    }
}

#Preview {
    TabView(selection: .constant(2)) {
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
    .environment(Auth.shared)
}
