import SwiftUI

struct ContentView: View {
    @Environment(Auth.self) var auth
    //@AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?
    var body: some View {
        Group {
            if auth.isAuthenticated {
                AuthenticatedView()
            } else {
                AnonymousView()
            }
        }
        .onAppear {
            print("isAuthenticated: " + (auth.isAuthenticated ? "Y" : "N"))
        }
    }
}

#Preview {
    ContentView()
}
