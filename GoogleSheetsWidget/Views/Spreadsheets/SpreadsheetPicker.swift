import SwiftUI
import OSLog

struct SpreadsheetPicker: View {
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SpreadsheetPicker")
    @Environment(Auth.self) var auth
    @State var spreadsheets: [Spreadsheet] = []
    
    var body: some View {
        List {
            if auth.isAuthenticated {
                Text("Authenticated").foregroundStyle(.green)
            } else {
                Text("Anonymous").foregroundStyle(.red)
            }
            ForEach(spreadsheets) { spreadsheet in
                Text(spreadsheet.name)
            }
        }
        .navigationTitle("Spreadsheet")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                try await load()
            } catch {
                log.error("failed retrieve spreadsheets because of \(error.localizedDescription)")
            }
        }
    }
    
    func load() async throws {
        guard let token = try await auth.refresh() else { return }
        
        guard var url = URL(string: "https://www.googleapis.com/drive/v3/files") else { return }
        
        url.append(queryItems: [URLQueryItem(name:"q",value:"mimeType='application/vnd.google-apps.spreadsheet'")])
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let result = try? JSONDecoder().decode(SpreadsheetsListResponse.self, from: data) else {
            log.info("invalid json")
            return
        }
        
        self.spreadsheets = result.files
    }
}

#Preview {
    NavigationStack {
        SpreadsheetPicker()
    }
    .environment(Auth())
}
