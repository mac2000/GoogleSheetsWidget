import SwiftUI
import SwiftData
import Shared

@main
struct Application: App {
    let u = URL(string: "")?.withFoo("a", "b")
    let auth = Auth()
    var body: some Scene {
        WindowGroup {
//            NavigationStack { SpreadsheetNavigationPicker() }
            ContentView()
                .environment(auth)
                .onOpenURL(perform: auth.exchange)
                .modelContainer(for: Watcher.self)
        }
    }
}
