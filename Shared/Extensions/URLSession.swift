import Foundation

public extension URLSession {
    func decoded<D>(_ url: URL) async throws -> D where D: Decodable {
        return try await self.decoded(URLRequest(url: url))
    }
    
    func decoded<D>(_ request: URLRequest) async throws -> D where D: Decodable {
        let (data, response) = try await self.data(for: request)
        
        let body = String(data: data, encoding: .utf8) ?? ""
        
        guard let httpsReponse = response as? HTTPURLResponse else {
            print(body)
            throw URLError(.badServerResponse)
        }
        
        guard httpsReponse.statusCode == 200 else {
            print(body)
            throw URLError(URLError.Code(rawValue: httpsReponse.statusCode))
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // return try decoder.decode(D.self, from: data)
        do {
            return try decoder.decode(D.self, from: data)
        } catch {
            print(body)
            throw error
        }
    }
}
