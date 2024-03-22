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
    
    let columns: [String] = (Unicode.Scalar("A").value...Unicode.Scalar("Z").value).map{"\(UnicodeScalar($0)!)"}
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $item.title)
            }
            
            Section("Spreadsheet") {
                Picker("Spreadsheet", selection: $selectedSpreadsheet) {
                    Text("Unknown").tag(Optional<Spreadsheet>.none)
                    ForEach(spreadsheets) { spreadsheet in
                        Text(spreadsheet.name).tag(Optional(spreadsheet))
                    }
                }.onChange(of: selectedSpreadsheet) {
                    if selectedSpreadsheet != nil {
                        item.spreadsheetId = selectedSpreadsheet!.id
                        item.spreadsheetName = selectedSpreadsheet!.name
                        Task {
                            self.sheets = try await self.loadSheets()
                        }
                    }
                }
                
                if selectedSpreadsheet != nil {
                    Picker("Sheet", selection: $item.sheetName) {
                        Text("Unknown").tag(Optional<String>.none)
                        ForEach(sheets, id: \.self) { sheet in
                            Text(sheet).tag(Optional(sheet))
                        }
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
        }
        .navigationTitle("Track")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                self.spreadsheets = try await load()
                let found = self.spreadsheets.first { spreadsheet in
                    spreadsheet.id == item.spreadsheetId
                }
                if found != nil {
                    self.selectedSpreadsheet = found
                } else {
                    self.selectedSpreadsheet = self.spreadsheets[0]
                }
                self.sheets = try await loadSheets()
            } catch {
                log.error("failed retrieve spreadsheets because of \(error.localizedDescription)")
            }
        }
        
    }
    
    func load() async throws -> [Spreadsheet] {
        guard let token = await auth.refresh() else { return [] }
        return await GoogleSheets.getSpreadsheets(token, "")
    }
    
    func loadSheets() async throws -> [String] {
        if item.spreadsheetId != nil {
            guard let token = await auth.refresh() else { return [] }
            return await GoogleSheets.getSheets(token, item.spreadsheetId!)
        }
        return []
    }
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
