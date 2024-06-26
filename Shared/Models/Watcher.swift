import SwiftUI
import SwiftData

@Model
public final class Watcher: Sendable {
    public var title: String
    public var value: String

    public var spreadsheetId: String
    public var spreadsheetName: String

    public var sheetName: String
    public var column: String
    public var row: Int
    
    public var colored: Bool = false

    public var isEmpty: Bool {
        return title.isEmpty  || spreadsheetName == "" || sheetName == ""
    }
    
    public func setValue(value: String) {
        self.value = value
    }
    
    public var color: Color {
        if self.value == "" {
            return .secondary
        }
        
        if !self.colored {
            return .primary
        }
        
        let v = self.value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        if v.hasPrefix("-") || v.hasPrefix("$ (") || v.hasPrefix("$ -") || v.hasPrefix("$-") {
            return .red
        }
        
        return .green
    }
    
    public init(title: String, spreadsheetId: String, spreadsheetName: String, sheetName: String, column: String, row: Int) {
        self.title = title
        self.value = ""
        self.spreadsheetId = spreadsheetId
        self.spreadsheetName = spreadsheetName
        self.sheetName = sheetName
        self.column = column
        self.row = row
        self.colored = false
    }
    
    public func eq(item: Watcher?) -> Bool {
        guard let item = item else { return false }
        if self.spreadsheetId != item.spreadsheetId {return false}
        if self.sheetName != item.sheetName {return false}
        if self.column != item.column {return false}
        if self.row != item.row {return false}
        return true
    }
    
}

extension Watcher {
    public static let example1 = Watcher(title: "Hello", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 1)
    public static let example2 = Watcher(title: "World", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 2)
    public static let example3 = Watcher(title: "Demo", spreadsheetId: "2", spreadsheetName: "Sample", sheetName: "Sheet1", column: "A", row: 1)
}
