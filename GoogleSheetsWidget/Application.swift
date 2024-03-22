import SwiftUI
import SwiftData
import Shared

@main
struct Application: App {
    let auth = Auth()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
                .onOpenURL(perform: auth.exchange)
                .modelContainer(for: Watcher.self)
        }
    }
}
