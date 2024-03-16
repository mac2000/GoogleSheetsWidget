import SwiftUI

struct AuthenticatedView: View {
    var body: some View {
        TabView{
            WatchingListView().tabItem {
                Label("Data", systemImage: "doc.text")
            }
            WidgetsView().tabItem {
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
        .environment(Auth())
}
