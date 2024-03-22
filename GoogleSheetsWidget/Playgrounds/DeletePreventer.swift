import SwiftUI

struct DeletePreventer: View {
    @State private var items = ["item 1", "item 2", "item 3"]
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .deleteDisabled(item.contains("1"))
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let item = items[index]
                    if item.contains("2") || item.contains("3") {
                        items.remove(at: index)
                    }
                }
            })
        }
    }
}

#Preview {
    DeletePreventer()
}
