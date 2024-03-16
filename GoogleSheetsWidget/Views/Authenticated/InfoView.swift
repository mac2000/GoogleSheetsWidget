import SwiftUI
import OSLog

struct InfoView: View {
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "InfoView")
    @Environment(Auth.self) var auth
    @State private var message = "Authenticated"
    @AppStorage("access_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var accessToken: String?
    @AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Message") {
                    Text(message)
                }
                Section("Actions") {
                    Button("Logout", action: auth.logout)
                    Button("Refresh", action: renew)
                    Button("Demo", action: demo)
                }
            }
            .navigationBarTitle("Settings")
        }
    }
    
    func demo() {
        var url = URL(string: "https://www.googleapis.com/drive/v3/files")!
        url.append(queryItems: [URLQueryItem(name:"q",value:"mimeType='application/vnd.google-apps.spreadsheet'")])
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                log.error("\(error)")
                message = error.localizedDescription
                return
            }
            guard let data = data else {
                log.warning("no data")
                message = "No data"
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let files = json["files"] as? [Any] {
                        log.info("Got \(files.count) files")
                        message = "Got \(files.count) files"
                    } else {
                        if let error = json["error"] as? [String: Any] {
                            if let message = error["message"] as? String {
                                self.message = message
                            } else {
                                self.message = "unknown"
                            }
                        } else {
                            self.message = "no files"
                        }
                    }
                }
            } catch {
                log.warning("\(error.localizedDescription)")
                message = error.localizedDescription
            }
        }.resume()
    }
    
    func renew() {
        Task {
            do {
                let accessToken = try await auth.refresh()
                log.info("refreshed")
                message = "refreshed"
            } catch {
                log.error("\(error.localizedDescription)")
                message = error.localizedDescription
            }
        }
    }
}

#Preview {
    TabView(selection: .constant(3)) {
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
    .environment(Auth())
}
