import SwiftUI

struct AsyncViewFuncs: View {
    @State private var items: [Post] = []
    
    var body: some View {
        List {
            ForEach(items) { item in
                Text(item.title)
            }
        }
        .task { await self.load() }
    }
    
    @MainActor func load() async {
        do {
            let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            //let (data, _) = try await URLSession.shared.data(from: url)
            //let items = try JSONDecoder().decode([Post].self, from: data)
            //self.items = items
            self.items = try await URLSession.shared.decoded(url)
        } catch {
            print(error)
        }
    }
}

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
}

#Preview {
    AsyncViewFuncs()
}
