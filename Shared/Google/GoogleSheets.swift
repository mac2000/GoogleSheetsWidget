import Foundation
import OSLog

public final actor GoogleSheets: Sendable {
    private static let log = Logger("GoogleSheets")
    
    public static func getSpreadsheets(_ accessToken: String, _ search: String) async -> [Spreadsheet] {
        guard let url = URL("https://www.googleapis.com/drive/v3/files", ["q" : q(search)]) else { return [] }
        let request = URLRequest(url: url, accessToken: accessToken)
        let response: GetSpreadsheetsResponse? = try? await URLSession.shared.decoded(request)
        return response?.files ?? []
    }
    
    public static func getSheets(_ accessToken: String, _ spreadsheetId: String) async -> [String] {
        guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/"+spreadsheetId) else { return [] }
        let request = URLRequest(url: url, accessToken: accessToken)
        let response: GetSheetsResponse? = try? await URLSession.shared.decoded(request)
        return (response?.sheets ?? []).map { $0.properties.title }
    }
    
    public static func getValues(_ accessToken: String, _ spreadsheetId: String, _ sheetName: String, _ range: String) async -> [[String]] {
        guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!\(range)") else { return [[]] }
        let request = URLRequest(url: url, accessToken: accessToken)
        let response: GetValueResponse? = try? await URLSession.shared.decoded(request)
        return response?.values ?? [[]]
    }
    
    public static func getValue(_ accessToken: String, _ spreadsheetId: String, _ sheetName: String, _ column: String, _ row: Int) async -> String {
        guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!\(column)\(row)") else { return "" }
        let request = URLRequest(url: url, accessToken: accessToken)
        let response: GetValueResponse? = try? await URLSession.shared.decoded(request)
        return response?.values.first?.first ?? ""
    }
    
    private static func q(_ search: String) -> String {
        if search == "" {
            return "mimeType='application/vnd.google-apps.spreadsheet'"
        } else {
            let name = search.replacingOccurrences(of: "'", with: "\'")
            return "mimeType='application/vnd.google-apps.spreadsheet' and name contains '\(name)'"
        }
    }
}

public struct GoogleSheetsPreview {
    public static let spreadsheets: [Spreadsheet] = [
        Spreadsheet(id: "1", name: "Demo"),
        Spreadsheet(id: "2", name: "Hello"),
        Spreadsheet(id: "3", name: "Untitled")
    ]
    
    public static let sheets: [String] = [ "Sheet1", "Sheet2", "Sheet3" ]
}

struct GetSpreadsheetsResponse: Codable {
    let files: [Spreadsheet]
}

public struct Spreadsheet: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct GetSheetsResponse: Codable, Identifiable {
    var id: String { spreadsheetId }
    let spreadsheetId: String
    let spreadsheetUrl: String
    let sheets: [SheetItem]
}

struct SheetItem: Codable {
    let properties: SheetItemProperties
}

struct SheetItemProperties: Codable, Identifiable {
    var id: Int { sheetId }
    let sheetId: Int
    let title: String
    let index: Int
}

struct GetValueResponse: Codable {
    let range: String
    let majorDimension: String
    let values: [[String]]
}
