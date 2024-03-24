import SwiftUI

struct NumberExtractor: View {
    var items = ["AAPL", "", "$149.5", "0.5%", "-2%", "$ (5.2)", "$ 1 000 000.00"]
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item).foregroundStyle(color(item))
            }
        }
    }
    
    func color(_ value: String) -> Color {
        if value == "" {
            return .secondary
        }
        
        guard let num = extractNumber(from: value) else {
            return .primary
        }
        
        return num < 0 ? .red : .green
    }
    
    private func extractNumber(from string: String) -> Double? {
        let cleanedString = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "[^0-9.-]+", with: "", options: .regularExpression)
        
        guard let number = Double(cleanedString) else {
            return nil
        }
        
        if string.hasSuffix("%") {
            return number
        }
        
        // Remove non-numeric characters except for '.' and '-'
        
        
        // "0.5%", "-2%"
        if string.contains("%"), let percentage = Double(cleanedString) {
            return percentage
        }
        
        // Attempt to convert the cleaned string to a Double
        if let number = Double(cleanedString) {
            return number
        }
        
        
        
        // Check for negative currency format (e.g., "$ (5.2)")
        if string.hasPrefix("$ (") {
            let negativeCleanedString = cleanedString.replacingOccurrences(of: "[^0-9.]+", with: "", options: .regularExpression)
            if let negativeCurrencyNumber = Double(negativeCleanedString) {
                return negativeCurrencyNumber * -1.0
            }
        }
        
        // Check for currency format (e.g., "$149.5")
        if string.hasPrefix("$"), let currencyNumber = Double(cleanedString) {
            return currencyNumber
        }
        
        // Return nil if no number could be extracted
        return nil
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func extract(_ regex: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let match = results {
                return nsString.substring(with: match.range)
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

#Preview {
    NumberExtractor()
}
