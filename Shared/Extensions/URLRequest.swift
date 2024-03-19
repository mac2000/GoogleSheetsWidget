import Foundation

public extension URLRequest {
    init(url: URL, accessToken: String) {
        self.init(url: url)
        self.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    init?(url: String, accessToken: String) {
        guard let url = URL(string: url) else { return nil }
        self.init(url: url, accessToken: accessToken)
    }
    
    init?(_ url: String, _ form: [String: String]) {
        guard let url = URL(string: url) else { return nil }
        self.init(url: url)
        
        var components = URLComponents()
        components.queryItems = form.map { item in
            URLQueryItem(name: item.key, value: item.value)
        }
        
        self.httpMethod = "POST"
        self.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.httpBody = components.query?.data(using: .utf8)
    }
}
