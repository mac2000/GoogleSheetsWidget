import SwiftUI

struct InfoView: View {
    @State private var message = "Authenticated"
    @AppStorage("access_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var accessToken: String?
    @AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header:Text("Message")) {
                    Text(message)
                }
                Section {
                    Button("Logout", action: logout)
                    Button("Refresh", action: renew)
                    Button("Demo", action: demo)
                }
            }
            .navigationBarTitle("Settings")
        }
    }
    
    func logout() {
        print("logout")
        accessToken = nil
        refreshToken = nil
    }
    
    func demo() {
        var url = URL(string: "https://www.googleapis.com/drive/v3/files")!
        url.append(queryItems: [URLQueryItem(name:"q",value:"mimeType='application/vnd.google-apps.spreadsheet'")])
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                message = error.localizedDescription
                return
            }
            guard let data = data else {
                print("No data received")
                message = "No data"
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let files = json["files"] as? [Any] {
                        print("Got \(files.count) files")
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
                print(error.localizedDescription)
                message = error.localizedDescription
            }
        }.resume()
    }
    
    func renew() {
        var parameters = URLComponents()
        parameters.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: "165877850855-o5k0ftcnlh8cukro95ujd4vspbghfp58.apps.googleusercontent.com")
        ]
        
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                message = error.localizedDescription
                return
            }
            guard let data = data else {
                print("No data received")
                message = "No data"
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let accessToken = json["access_token"] as? String {
                        self.accessToken = accessToken
                        print("refreshed")
                        message = "Refreshed"
                    } else {
                        print("token missing in json")
                        self.accessToken = nil
                        self.refreshToken = nil
                        message = "token missing"
                    }
                }
            } catch {
                print(error.localizedDescription)
                message = error.localizedDescription
            }
        }.resume()
    }
}

#Preview {
    InfoView()
}
