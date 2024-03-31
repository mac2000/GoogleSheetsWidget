import SwiftUI
import SwiftData
import Shared
import WidgetKit


struct WidgetsTab: View {
    var body: some View {
        NavigationStack {
            Text("TODO")
        }
    }
}

#Preview {
    TabView(selection: .constant(2)) {
        Text("Data").tabItem {
            Label("Data", systemImage: "doc.text")
        }.tag(1)
        WidgetsTab().tabItem {
            Label("Widgets", systemImage: "square.grid.3x2")
        }.tag(2)
        Text("Settings").tabItem {
            Label("Settings", systemImage: "gear")
        }.tag(3)
    }
    .environment(Auth.shared)
}
