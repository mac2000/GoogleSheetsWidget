import SwiftUI

struct PreviewApi: View {
    // https://developers.google.com/oauthplayground
    // step1: https://www.googleapis.com/auth/drive.readonly
    let accessToken = "ya29.a0Ad52N3_PIZ_0yWxYqxjzC23sfKwld8PituLe84QEdDplBF8ZSXAPAsIzxYu3iZePXt7RfvKdR_MUE1Qk7bj2ppr7XFPVdn892jYarCheoUFn_T3QexE6WlbNWdVO2TUkpsrOHiuJa_CG1aJMtRj7UUhczR4JIasB0VffaCgYKAWkSARASFQHGX2MiQNHbpZkK2CCXF_Cw--_rqg0171"
    @Environment(\.dismiss) var dismiss
    @State private var loading = false
    @Binding var item: Spreadsheet?
    @State private var items: [Spreadsheet] = []
    //@State private var search = ""
    @StateObject private var search = DebouncedState(initialValue: "")
    
    var body: some View {
        List(items, selection: $item) { item in
            Text(item.name).tag(item)
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
        //.refreshable { await load() }
        .searchable(text: $search.currentValue)
        .onChange(of: search.debouncedValue, { oldValue, newValue in
            Task { await load() }
        })
        //.onSubmit(of: .search) {
        //    Task { await load() }
        //}
        .onChange(of: item) { _, _ in
            dismiss()
        }
    }
    
    var q: String {
        if search.debouncedValue == "" {
            return "mimeType='application/vnd.google-apps.spreadsheet'"
        } else {
            let name = search.debouncedValue.replacingOccurrences(of: "'", with: "\'")
            return "mimeType='application/vnd.google-apps.spreadsheet' and name contains '\(name)'"
        }
    }
    
    func load() async {
        loading = true
        defer {
            loading = false
        }
        
        guard let url = URL(string: "https://www.googleapis.com/drive/v3/files")?.withQueryStringParameter("q", q) else { return }
        
        print("URL", url)
        let request = URLRequest(url: url, accessToken: accessToken)
        
        let response: SpreadsheetsListResponse? = try? await URLSession.shared.decoded(request)
        
        self.items = response?.files ?? []
    }
}


#Preview {
    NavigationStack {
        PreviewApi(item: .constant(Spreadsheet(id: "1", name: "String")))
    }
}
