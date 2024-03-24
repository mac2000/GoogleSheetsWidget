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
    
    public var numeric: Bool = false
    public var colored: Bool = false

    public var isEmpty: Bool {
        return title.isEmpty  || spreadsheetName == "" || sheetName == ""
    }
    
    public var color: Color {
        if !self.numeric {
            return .primary
        }
        
        guard let number = self.extractNumber(from: self.value) else {
            return .primary
        }
        
        return number < 0 ? .red : .green
    }
    
    public init(title: String, spreadsheetId: String, spreadsheetName: String, sheetName: String, column: String, row: Int) {
        self.title = title
        self.value = ""
        self.spreadsheetId = spreadsheetId
        self.spreadsheetName = spreadsheetName
        self.sheetName = sheetName
        self.column = column
        self.row = row
        self.numeric = false
        self.colored = false
    }
    
    public func setValue(value: String) {
        self.value = value
    }
    
    private func extractNumber(from string: String) -> Double? {
        // Remove non-numeric characters except for '.' and '-'
        let cleanedString = string.replacingOccurrences(of: "[^0-9.-]+", with: "", options: .regularExpression)
        
        // Attempt to convert the cleaned string to a Double
        if let number = Double(cleanedString) {
            return number
        }
        
        // Check for percentage format (e.g., "0.5%")
        if string.contains("%"), let percentage = Double(cleanedString) {
            return percentage / 100.0
        }
        
        // Check for negative numbers (e.g., "-2%")
        if string.contains("-"), let negativeNumber = Double(cleanedString) {
            return negativeNumber * -1.0
        }
        
        // Check for currency format (e.g., "$149.5")
        if string.hasPrefix("$"), let currencyNumber = Double(cleanedString) {
            return currencyNumber
        }
        
        // Check for negative currency format (e.g., "$ (5.2)")
        if string.hasPrefix("$ (") {
            let negativeCleanedString = cleanedString.replacingOccurrences(of: "[^0-9.]+", with: "", options: .regularExpression)
            if let negativeCurrencyNumber = Double(negativeCleanedString) {
                return negativeCurrencyNumber * -1.0
            }
        }
        
        // Return nil if no number could be extracted
        return nil
    }

    
    #if DEBUG
    public static let example1 = Watcher(title: "Hello", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 1)
    public static let example2 = Watcher(title: "World", spreadsheetId: "1", spreadsheetName: "Demo", sheetName: "Sheet1", column: "A", row: 2)
    public static let example3 = Watcher(title: "Demo", spreadsheetId: "2", spreadsheetName: "Sample", sheetName: "Sheet1", column: "A", row: 1)
    #endif
}
