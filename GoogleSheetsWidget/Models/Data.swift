import SwiftUI
import SwiftData

@Model
class Watcher {
    var title: String
    var value: String?

    var spreadsheetId: String?
    var spreadsheetName: String?

    var sheetName: String?
    var column: String
    var row: Int

    var isEmpty: Bool {
        return title.isEmpty || spreadsheetName == nil || spreadsheetName == "" || sheetName == nil || sheetName == ""
    }
    
    init(title: String, spreadsheetId: String, spreadsheetName: String, sheetName: String, column: String, row: Int) {
        self.title = title
        self.spreadsheetId = spreadsheetId
        self.spreadsheetName = spreadsheetName
        self.sheetName = sheetName
        self.column = column
        self.row = row
    }
    
    public func setValue(value: String?) {
        self.value = value
    }
    
    #if DEBUG
    static let example1 = Watcher(title: "Hello", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 1)
    static let example2 = Watcher(title: "World", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 2)
    static let example3 = Watcher(title: "Demo", spreadsheetId: "2", spreadsheetName: "Sample", sheetName: "Sheet1", column: "A", row: 1)
    #endif
}
