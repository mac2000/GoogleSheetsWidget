import SwiftUI

struct AuthenticatedView: View {
    var body: some View {
        TabView{
            DataTab().tabItem {
                Label("Data", systemImage: "doc.text")
            }
            WidgetsTab().tabItem {
                Label("Widgets", systemImage: "square.grid.3x2")
            }
            SettingsTab().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    AuthenticatedView()
        .environment(Auth())
}
