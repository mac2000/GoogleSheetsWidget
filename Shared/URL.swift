import Foundation

public extension URL {
    func withFoo(_ key: String, _ val: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var queryItems = components?.queryItems ?? []
        
        if let index = queryItems.firstIndex(where: { $0.name == key }) {
            queryItems[index] = URLQueryItem(name: key, value: val)
        } else {
            queryItems.append(URLQueryItem(name: key, value: val))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
}
