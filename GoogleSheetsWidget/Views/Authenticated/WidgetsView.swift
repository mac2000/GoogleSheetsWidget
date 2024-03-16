import SwiftUI

struct WidgetsView: View {
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
}
