import SwiftUI

import SwiftUI
import SwiftData

@main
struct Application: App {
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
