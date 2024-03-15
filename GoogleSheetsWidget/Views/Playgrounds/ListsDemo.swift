import SwiftUI

struct ListsDemo: View {
    @State private var items: [String] = [
        "Item 1",
        "Item 2",
        "Item 3"
    ]
    
    var body: some View {
        NavigationStack{
            List {
                if items.count == 0 {
                    ContentUnavailableView("nothing yet", systemImage: "list.bullet")
                } else {
                    ForEach(items, id: \.self) { item in
                        NavigationLink(value: item) {
                            Text(item)
                        }
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
            }
            .refreshable {
                print("refreshing")
                items = [
                    "Item 1",
                    "Item 2",
                    "Item 3"
                ]
            }
            .navigationTitle("Lists")
            .navigationDestination(for: String.self, destination: { item in
                Text(item)
            })
            .toolbar {
                ToolbarItem(placement:.bottomBar) {
                    Button {
                        items.append("Item \(items.count+1)")
                    } label: {
                        Text("Add Item")
                            .frame(width: 100, height: 40)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
            }
            
        }
    }
    
    func move(from: IndexSet, to: Int) {
        print("moving \(from) \(to)")
        items.move(fromOffsets: from, toOffset: to)
    }
    
    func delete(at offsets: IndexSet) {
        print("deleteing \(offsets)")
        items.remove(atOffsets: offsets)
    }
}

#Preview {
    ListsDemo()
}
