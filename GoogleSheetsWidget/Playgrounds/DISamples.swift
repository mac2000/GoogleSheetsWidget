import SwiftUI
import Combine

struct PostsModel: Codable, Identifiable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}


protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostsModel], Error>
}


final class ProductionDataService: DataServiceProtocol {
    //let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostsModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

final class MockDataService: DataServiceProtocol {
    let items: [PostsModel]
    
    init(items: [PostsModel]?) {
        self.items = items ?? [
            PostsModel(userId: 1, id: 1, title: "Title 1", body: "Body 1"),
            PostsModel(userId: 2, id: 2, title: "Title 2", body: "Body 2")
        ]
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        Just(items)
            .tryMap({ $0 })
            .eraseToAnyPublisher()
    }
}

@Observable
final class DIVM {
    var items: [PostsModel] = []
    var cancellables = Set<AnyCancellable>()
    let dataService: DataServiceProtocol
    
    nonisolated init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
            } receiveValue: { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
            
    }
}

struct DISamples: View {
    @State private var vm: DIVM
    init(dataService: DataServiceProtocol) {
        self.vm = DIVM(dataService: dataService)
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.items) { item in
                    Text(item.title)
                }
            }
        }
    }
}

#Preview {
    let prod = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    let mock = MockDataService(items: nil)
    return DISamples(dataService: mock)
}
