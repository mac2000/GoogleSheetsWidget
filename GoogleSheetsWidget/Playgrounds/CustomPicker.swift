import SwiftUI
import Combine

struct CustomPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @State var loading = false
    @Binding var item: CustomPickerItem?
    @State var items: [CustomPickerItem] = []
    @StateObject private var search = DebouncedState(initialValue: "")
    
    var body: some View {
        List(selection: $item) {
            ForEach(items) { item in
                Text(item.name).tag(item)
            }
        }
        .overlay {
            if loading {
                ContentUnavailableView("Loading", systemImage: "arrow.down.circle.dotted", description: Text("Retrieving items list"))
            }
            else if items.isEmpty {
                ContentUnavailableView("Empty", systemImage: "doc.text.magnifyingglass", description: Text("Empty list retrieved"))
            }
        }
        .navigationTitle("Custom picker")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .refreshable { await load() }
        .searchable(text: $search.currentValue)
        .onChange(of: search.debouncedValue, { oldValue, newValue in
            Task { await load() }
        })
        .onChange(of: item, { oldValue, newValue in
            guard let name = newValue?.name else { return }
            dismiss()
            print("Selected \(name)")
        })
    }
    
    func load() async {
        loading = true
        item = nil
        // pretend we are retrieving list from backend
        let sleepSeconds = 2
        try? await Task.sleep(nanoseconds: UInt64(sleepSeconds) * NSEC_PER_SEC)
        var items = (1...20).map { num in
            let name = "Item \(num)"
            return CustomPickerItem(id: "\(num)", name: name)
        }
        
        if search.debouncedValue != "" {
            items = items.filter { $0.name.localizedStandardContains(search.debouncedValue) }
        }
        
        self.items = items
        loading = false
    }
}

private class DebouncedState<Value>: ObservableObject {
    @Published var currentValue: Value
    @Published var debouncedValue: Value
    
    init(initialValue: Value, delay: Double = 0.3) {
        _currentValue = Published(initialValue: initialValue)
        _debouncedValue = Published(initialValue: initialValue)
        $currentValue
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedValue)
    }
}

struct CustomPickerItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}

//#Preview {
//    NavigationStack {
//        CustomPicker()
//    }
//}
