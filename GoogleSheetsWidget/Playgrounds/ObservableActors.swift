import SwiftUI

struct Todo: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let completed: Bool
}

final actor Api {
    public static func getImage() async throws -> UIImage {
        return try await URLSession.shared.decoded(string: "https://picsum.photos/600")
    }
    
    public static func getTodos() async throws -> [Todo] {
        return try await URLSession.shared.decoded(string: "https://jsonplaceholder.typicode.com/todos")
    }
}

@Observable @MainActor final class Storage {
    public var message: String = ""
    public var image: UIImage? = nil
    public var items: [Todo] = []
    
    public func setMessage(_ message: String) async {
        self.message = message
    }
    
    public func loadImage() async {
        if let image: UIImage = try? await URLSession.shared.decoded(string: "https://picsum.photos/600") {
            self.image = image
        }
    }
    
    public func loadTodos() async {
        if let items: [Todo] = try? await Api.getTodos() {
            self.items = items
        }
        //if let items: [Todo] = try? await URLSession.shared.decoded(string: "https://jsonplaceholder.typicode.com/todos") {
        //    self.items = items
        //}
    }
}

struct ObservableActors: View {
    @Environment(Storage.self) private var storage
    var body: some View {
        VStack {
            Text(storage.message)
            if let image = storage.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            Button("click me") {
                Task {
                    await self.storage.setMessage("World")
                    await self.storage.loadImage()
                }
            }
            Text("todos: \(self.storage.items.count)")
        }
        .task {
            self.storage.message = "Hello"
            await self.storage.loadImage()
            await self.storage.loadTodos()
        }
    }
}

extension URLSession {
    public func decoded(from url: URL) async throws -> UIImage {
        let (data, _) = try await self.data(from: url)
        guard let image = UIImage(data: data) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode image data."))
        }
        return image
    }
    
    public func decoded(string: String) async throws -> UIImage {
        guard let url = URL(string: string) else { throw URLError(.badURL) }
        return try await decoded(from: url)
    }
    
    public func decoded<D>(from url: URL) async throws -> D where D: Decodable {
        return try await self.decoded(URLRequest(url: url))
    }
    
    public func decoded<D>(string: String) async throws -> D where D: Decodable {
        guard let url = URL(string: string) else { throw URLError(.badURL) }
        return try await self.decoded(URLRequest(url: url))
    }
    
    public func decoded<D>(_ request: URLRequest) async throws -> D where D: Decodable {
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

#Preview {
    ObservableActors()
        .environment(Storage())
}
