import SwiftUI

struct Watch: Codable, Identifiable, Hashable {
    var title: String
    var spreadsheetId: String
    var spreadsheetName: String
    var sheetName: String
    var column: String
    var row: Int
    var id: String {"\(spreadsheetId)/\(sheetName)!\(column)\(row)"}
    var value: String?
}

struct WatchingList: View {
    @AppStorage("access_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var accessToken: String?
    @AppStorage("refresh_token",store: UserDefaults.init(suiteName: "group.GoogleSheetsWidget")) var refreshToken: String?
    
    @State private var items: [Watch] = [
        Watch(title: "cell1", spreadsheetId: "spreadsheet1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 1, value: nil),
        Watch(title: "cell2", spreadsheetId: "spreadsheet1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "B", row: 1, value: nil),
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack{
                            VStack(alignment:.leading){
                                Text(item.title)
                                HStack{
                                    Text("\(item.sheetName)!\(item.column)\(item.row)")
                                    Text("/")
                                    Text(item.spreadsheetName)
                                }.font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer()
                            Text(item.value ?? "N/A")
                        }
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .toolbar {
                Button("Add") {
                    print("add")
                }
//                ToolbarItem(placement:.bottomBar) {
//                    Button {
//                        print("add")
//                    } label: {
//                        Text("Add Item")
//                            .frame(width: 100, height: 40)
//                            .foregroundColor(.white)
//                            .background(.blue)
//                            .cornerRadius(10)
//                    }
//                }
            }
            .refreshable {
                print("refreshing")
                items = [
                    Watch(title: "cell1", spreadsheetId: "spreadsheet1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 1, value: nil),
                    Watch(title: "cell2", spreadsheetId: "spreadsheet1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "B", row: 1, value: nil),
                ]
            }
            .navigationTitle("List")
            .navigationDestination(for: Watch.self) { item in
                Text(item.title)
            }
        }
    }
    
    func move(from: IndexSet, to: Int) {
        print("moving \(from) \(to)")
        items.move(fromOffsets: from, toOffset: to)
    }
    
    func delete(at offsets: IndexSet) {
        print("deleteing")
        items.remove(atOffsets: offsets)
    }
}

#Preview {
    WatchingList()
}
