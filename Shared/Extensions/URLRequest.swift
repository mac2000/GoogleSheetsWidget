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
}
