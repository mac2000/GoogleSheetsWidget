import SwiftUI

struct PreviewApi: View {
    // https://developers.google.com/oauthplayground
    // step1: https://www.googleapis.com/auth/drive.readonly
    let accessToken = "ya29.a0Ad52N39PiBQ30ULnJZKYssbFASdsgT1kaBPhFaq6k03efBBStILc63Laq4Zw9NyQrGoEUO1Ldl5_xGLKG68TDh6wR0hNjDK1l525y30atZEtR3tHbCiF_f8tEz27uUDPgWWbfMmXWejwyz4pC0Qf41bds_XH6V9nqORPaCgYKAR0SARASFQHGX2MiawQ5cPWcAK0jEi4uOrOprQ0171"
    
    @State private var loading = false
    @State private var item: Spreadsheet?
    @State private var items: [Spreadsheet] = []
    //@State private var search = ""
    @StateObject private var search = DebouncedState(initialValue: "")
    
    var body: some View {
        List(selection: $item) {
            ForEach(items) { item in
                Text(item.name).tag(item)
            }
        }
        .overlay {
            if loading {
                ContentUnavailableView("Loading", systemImage: "arrow.down.circle.dotted", description: Text("Retrieving items list"))
            }
            else if items.isEmpty {
                ContentUnavailableView("Empty", systemImage: "doc.text.magnifyingglass", description: Text("Empty list retrieved"))
            }
        }
        .navigationTitle("Spreadsheet")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .refreshable { await load() }
        .searchable(text: $search.currentValue)
        .onChange(of: search.debouncedValue, { oldValue, newValue in
            Task { await load() }
        })
        .onSubmit(of: .search) {
            Task { await load() }
        }
        .onChange(of: item) { oldValue, newValue in
            guard let item = newValue else { return }
            print("Selected \(item.name)")
        }
    }
    
    func load() async {
        loading = true
        item = nil
        print("loading '\(search.debouncedValue)'")
        let q = search.debouncedValue == "" ? "mimeType='application/vnd.google-apps.spreadsheet'" : "mimeType='application/vnd.google-apps.spreadsheet' and name contains '\(search.debouncedValue)'"
        
        var url = URL(string: "https://www.googleapis.com/drive/v3/files")!
        url.append(queryItems: [URLQueryItem(name:"q",value:q)])
        
        let request = URLRequest(url: url, accessToken: accessToken)
        
        let response: SpreadsheetsListResponse? = try? await URLSession.shared.decoded(request)
        
        self.items = response?.files ?? []
        loading = false
    }
}

private class DebouncedState<Value>: ObservableObject {
    @Published var currentValue: Value
    @Published var debouncedValue: Value
    
    init(initialValue: Value, delay: Double = 0.3) {
        _currentValue = Published(initialValue: initialValue)
        _debouncedValue = Published(initialValue: initialValue)
        $currentValue
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedValue)
    }
}

extension URLRequest {
    init(url: URL, accessToken: String) {
        self.init(url: url)
        self.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    init(url: String, accessToken: String) {
        self.init(url: URL(string: url)!, accessToken: accessToken)
    }
}

extension URLSession {
    func decoded<D>(_ request: URLRequest) async throws -> D where D: Decodable {
        let (data, response) = try await self.data(for: request)
        
        guard let httpsReponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpsReponse.statusCode == 200 else {
            throw URLError(URLError.Code(rawValue: httpsReponse.statusCode))
        }
        
        return try JSONDecoder().decode(D.self, from: data)
    }
}

#Preview {
    NavigationStack {
        PreviewApi()
    }
}
