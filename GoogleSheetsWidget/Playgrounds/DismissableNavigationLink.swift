import SwiftUI

struct DismissableNavigationLinkDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var item: String?
    let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    var body: some View {
        List(selection: $item) {
            ForEach(items, id: \.self, content: Text.init)
        }
        .onChange(of: item) { oldValue, newValue in
            guard let item = newValue else { return }
            print("Selected: \(item)")
            dismiss()
        }
    }
}

struct DismissableNavigationLink: View {
    @State private var item: String?
    var body: some View {
        Form {
            NavigationLink {
                DismissableNavigationLinkDetailView(item: $item)
            } label: {
                HStack {
                    Text("Custom")
                    Spacer()
                    Text(item ?? "N/A")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DismissableNavigationLink()
    }
}
