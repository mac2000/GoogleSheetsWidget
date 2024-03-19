import SwiftUI
import SwiftData
import Shared

@main
struct Application: App {
    let auth = Auth()
    var body: some Scene {
        WindowGroup {
//            NavigationStack { SpreadsheetNavigationPicker() }
            ContentView()
                .environment(auth)
                .onOpenURL(perform: self.onOpenURL) // auth.exchange)
                .modelContainer(for: Watcher.self)
        }
    }
    
    func onOpenURL(_ url: URL) {
        Task {
            let response = await GoogleAuth.exchange(url)
            print("retrieved", response?.refreshToken ?? "nil")
            let res2 = await GoogleAuth.refresh(response!.refreshToken)
            print("refreshed", res2 ?? "nil")
        }
    }
}
