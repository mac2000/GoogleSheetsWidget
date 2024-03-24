import SwiftUI
import SwiftData
import Shared

@main
struct Application: App {
    //let auth = Auth()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(Auth.shared)
                .onOpenURL(perform: { url in
                    Task {
                        await Auth.shared.exchange(url)
                    }
                })
                .modelContainer(for: Watcher.self)
        }
    }
}
