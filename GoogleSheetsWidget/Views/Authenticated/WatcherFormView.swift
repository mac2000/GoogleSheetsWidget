import SwiftUI
import SwiftData
import Shared
import OSLog

struct WatcherFormView: View {
    let log = Logger("WatcherFormView")
    @Environment(Auth.self) var auth
    @Bindable var item: Watcher
    
    @State var selectedSpreadsheet: Spreadsheet?
    @State var spreadsheets: [Spreadsheet] = []
    @State var sheets: [String] = []
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $item.title)
            }
            
            Section("Spreadsheet") {
                NavigationLink {
                    SpreadsheetPicker() { selected in
                        item.spreadsheetId = selectedSpreadsheet!.id
                        item.spreadsheetName = selectedSpreadsheet!.name
                        Task {
                            self.sheets = await self.loadSheets()
                        }
                    }
                } label: {
                    HStack {
                        Text("Spreadsheet")
                        Spacer()
                        Text(selectedSpreadsheet?.name ?? "unkown")
                            .foregroundStyle(selectedSpreadsheet == nil ? .secondary : .primary)
                    }
                }
                
                if selectedSpreadsheet != nil {
                    Picker("Sheet", selection: $item.sheetName) {
                        Text("Unknown").tag(Optional<String>.none)
                        ForEach(sheets, id: \.self) { sheet in
                            Text(sheet).tag(Optional(sheet))
                        }
                    }.onChange(of: item.sheetName) { oldValue, newValue in
                        print("changed sheet")
                    }
                }
                
                Picker("Column", selection: $item.column) {
                    Text("Unknown").tag(Optional<String>.none)
                    ForEach(columns, id: \.self) { column in
                        Text(column)
                    }
                }
                
                Picker("Row", selection: $item.row) {
                    ForEach(1...30, id: \.self) { row in
                        Text("\(row)")
                    }
                }
            }
            
            Section("Preview") {
                CellView(item: item)
            }
        }
        .navigationTitle("Track")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            self.spreadsheets = await load()
            let found = self.spreadsheets.first { spreadsheet in
                spreadsheet.id == item.spreadsheetId
            }
            if found != nil {
                self.selectedSpreadsheet = found
            } else if !self.spreadsheets.isEmpty {
                self.selectedSpreadsheet = self.spreadsheets[0]
            }
            self.sheets = await loadSheets()
            await refresh()
        }
        .refreshable { await refresh() }
        
    }
    
    func load() async -> [Spreadsheet] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return GoogleSheetsPreview.spreadsheets
        }
        guard let accessToken = await auth.refresh() else { return [] }
        return await GoogleSheets.getSpreadsheets(accessToken, "")
    }
    
    func loadSheets() async -> [String] {
        if item.spreadsheetId != nil {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return GoogleSheetsPreview.sheets
            }
            guard let accessToken = await auth.refresh() else { return [] }
            return await GoogleSheets.getSheets(accessToken, item.spreadsheetId!)
        }
        return []
    }
    
    func refresh() async {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            item.value = "\(Int.random(in: 0...100))"
            return
        }
        guard let accessToken = await auth.refresh() else { return }
        if let spreadsheetId = item.spreadsheetId,
           let sheetName = item.sheetName {
            item.value = await GoogleSheets.getValue(accessToken, spreadsheetId, sheetName, item.column, item.row)
            print("refreshed")
        } else {
            print("not refreshed, some properties are empty")
        }
    }
    
    private let columns: [String] = (Unicode.Scalar("A").value...Unicode.Scalar("Z").value).map{"\(UnicodeScalar($0)!)"}
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Watcher.self, configurations: config)
        
        container.mainContext.insert(Watcher.example1)
        container.mainContext.insert(Watcher.example2)
        container.mainContext.insert(Watcher.example3)
        
        return TabView(selection: .constant(1)) {
            NavigationStack {
                WatcherFormView(item: Watcher.example1)
            }.tabItem {
                Label("Data", systemImage: "doc.text")
            }.tag(1)
            WidgetsTab().tabItem {
                Label("Widgets", systemImage: "square.grid.3x2")
            }.tag(2)
            SettingsTab().tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(3)
        }
        .environment(Auth())
        .modelContainer(container)
    } catch {
        fatalError("failed to create model container because of: \(error.localizedDescription)")
    }
}
