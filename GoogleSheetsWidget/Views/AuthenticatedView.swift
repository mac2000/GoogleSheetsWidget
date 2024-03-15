import SwiftUI

struct AuthenticatedView: View {
    var body: some View {
        TabView{
            WatchingList().tabItem {
                Label("Sheets", systemImage: "doc.text")
            }
            Text("Widgets").tabItem {
                Label("Widgets", systemImage: "square.grid.3x2")
            }
            InfoView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    AuthenticatedView()
}
