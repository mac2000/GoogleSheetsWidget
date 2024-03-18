import Foundation

public extension URL {
    init?(url: String, query: [String: String]) {
        guard var components = URLComponents(string: url) else { return nil }
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { return nil }
        self = url
    }
    
    func withQueryStringParameter(_ key: String, _ val: String) -> URL? {
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
    
    func withQueryStringParameters(_ queryItems: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var queryItems = components?.queryItems ?? []
        for item in queryItems {
            if let index = queryItems.firstIndex(where: { $0.name == item.name }) {
                queryItems[index] = URLQueryItem(name: item.name, value: item.value)
            } else {
                queryItems.append(URLQueryItem(name: item.name, value: item.value))
            }
        }
        components?.queryItems = queryItems
        return components?.url
    }
}

