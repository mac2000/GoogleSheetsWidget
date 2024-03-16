import SwiftUI
import OSLog

struct SpreadsheetPicker: View {
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SpreadsheetPicker")
    @Environment(Auth.self) var auth
    @State var spreadsheets: [Spreadsheet] = []
    
    var body: some View {
        List {
            Text("Hello, World!")
            Text(auth.isAuthenticated ? "Y" : "N")
        }
        .navigationTitle("Spreadsheet")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }
    
    func load() {
//        guard let accessToken = accessToken else { return }
//        guard var url = URL(string: "https://www.googleapis.com/drive/v3/files") else { return }
//        
//        url.append(queryItems: [URLQueryItem(name:"q",value:"mimeType='application/vnd.google-apps.spreadsheet'")])
//        
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            guard let data = data, let result = try? JSONDecoder().decode(SpreadsheetsListResponse.self, from: data) else {
//                log.info(error ?? "invalid json")
//                return
//            }
//            self.spreadsheets = result.files
//        }.resume()
    }
}

fileprivate struct SpreadsheetsListResponse: Codable {
    let files: [Spreadsheet]
}

struct Spreadsheet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}

#Preview {
    NavigationStack {
        SpreadsheetPicker()
    }
    .environment(Auth())
}
