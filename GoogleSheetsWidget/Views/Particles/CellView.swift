import SwiftUI

struct CellView: View {
    @Bindable var item: Watcher
    var selector: String {
        return "\(sheetName)!\(item.column)\(item.row)"
    }
    var spreadsheetName: String {
        return item.spreadsheetName ?? "unknown"
    }
    var sheetName: String {
        return item.sheetName ?? "unknown"
    }
    var value: String {
        return item.value ?? "n/a"
    }
    var color: HierarchicalShapeStyle {
        return item.value == nil ? .secondary : .primary
    }
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                Text(item.title)
                HStack{
                    Text(selector)
                    Text("/")
                    Text(spreadsheetName)
                }.font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Text(value).foregroundStyle(color)
        }
    }
}

#Preview {
    CellView(item: Watcher.example1)
}
