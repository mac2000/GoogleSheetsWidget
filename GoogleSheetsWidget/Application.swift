import SwiftUI
import SwiftData

@main
struct Application: App {
    let auth = Auth()
    //@AppStorage("access_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var accessToken: String?
    //@AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
                .onOpenURL(perform: auth.exchange)
                .modelContainer(for: Watcher.self)
        }
    }
    
    /*
    func handleCallback(_ url: URL) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        guard let codeVerifier = url.queryItems?.first(where: { $0.name == "state" })?.value else { return }
        guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        // guard let scope = url.queryItems?.first(where: { $0.name == "scope" })?.value else { return }
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeVerifier),
            URLQueryItem(name: "client_id", value: "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com"),
            URLQueryItem(name: "redirect_uri", value: "com.googleusercontent.apps.165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58:/callback"),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("invalid json")
                    self.accessToken = nil
                    self.refreshToken = nil
                    return
                }
                
                // print(json)

                guard let accessToken = json["access_token"] as? String, let refreshToken = json["refresh_token"] as? String else {
                    print("tokens missing")
                    self.accessToken = nil
                    self.refreshToken = nil
                    return
                }
                
                print("authenticated")
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            }
        }.resume()
    }
    */
}
