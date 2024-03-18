import SwiftUI
import OSLog

class GoogleSpreadsheets {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GoogleSpreadsheets")
    
    public static func getSpreadsheets(accessToken: String) async throws -> [Spreadsheet] {
        guard let url = URL(url: "https://www.googleapis.com/drive/v3/files", query: ["q" : "mimeType='application/vnd.google-apps.spreadsheet'"]) else { return [] }
        let request = URLRequest(url: url, accessToken: accessToken)
        guard let result: SpreadsheetsListResponse = try? await URLSession.shared.decoded(request) else { return [] }
        return result.files
        
        // ---
        /*
        guard var url = URL(string: "https://www.googleapis.com/drive/v3/files") else { return [] }
        
        url.append(queryItems: [URLQueryItem(name:"q",value:"mimeType='application/vnd.google-apps.spreadsheet'")])
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let result = try? JSONDecoder().decode(SpreadsheetsListResponse.self, from: data) else {
            log.info("invalid json")
            return []
        }
        
        return result.files
        */
    }
    
    public static func getSheets(accessToken: String, spreadsheetId: String) async throws -> [String] {
        guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/"+spreadsheetId) else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // request.timeoutInterval = . // TODO: request timeout
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let result = try? JSONDecoder().decode(GetSheetsResponse.self, from: data) else {
            log.info("invalid json")
            return []
        }
        
        var sheets: [String] = []
        for sheet in result.sheets {
            sheets.append(sheet.properties.title)
        }
        
        return sheets
    }
    
    public static func getValue(accessToken: String, spreadsheetId: String, sheetName: String, column: String, row: Int) async throws -> String {
        guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!\(column)\(row)") else { return "" }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // request.timeoutInterval = . // TODO: request timeout
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let result = try? JSONDecoder().decode(GetValueResponse.self, from: data) else {
            log.info("invalid json")
            return ""
        }
        
        return result.values[0][0]
    }
}

struct SpreadsheetsListResponse: Codable {
    let files: [Spreadsheet]
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

struct Spreadsheet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}
