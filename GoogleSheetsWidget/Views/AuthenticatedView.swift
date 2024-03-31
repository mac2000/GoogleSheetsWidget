import SwiftUI
import Shared

struct AuthenticatedView: View {
    var body: some View {
        TabView{
            DataTab().tabItem {
                Label("Data", systemImage: "doc.text")
            }
            SettingsTab().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    AuthenticatedView()
        .environment(Auth.shared)
}
