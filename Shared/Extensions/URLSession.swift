import Foundation

public extension URLSession {
    func decoded<D>(_ url: URL) async throws -> D where D: Decodable {
        let request = URLRequest(url: url)
        return try await self.decoded(request)
    }
    
    func decoded<D>(_ request: URLRequest) async throws -> D where D: Decodable {
        let (data, response) = try await self.data(for: request)
        
        guard let httpsReponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpsReponse.statusCode == 200 else {
            throw URLError(URLError.Code(rawValue: httpsReponse.statusCode))
        }
        
        return try JSONDecoder().decode(D.self, from: data)
    }
}
