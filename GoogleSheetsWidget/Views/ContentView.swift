import SwiftUI
import OSLog

struct ContentView: View {
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")
    @Environment(Auth.self) var auth
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                AuthenticatedView()
            } else {
                AnonymousView()
            }
        }
        .onAppear {
            log.info("isAuthenticated: \(auth.isAuthenticated ? "Y" : "N")")
        }
    }
}

#Preview {
    ContentView()
        .environment(Auth())
}
