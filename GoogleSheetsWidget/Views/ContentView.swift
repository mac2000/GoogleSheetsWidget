import SwiftUI

struct ContentView: View {
    @AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?
    var body: some View {
        if refreshToken == nil {
            AnonymousView()
        } else {
            AuthenticatedView()
        }
    }
}

#Preview {
    ContentView()
}
