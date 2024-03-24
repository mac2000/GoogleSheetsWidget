import WidgetKit
import SwiftUI
import SwiftData
import Shared

struct SimpleEntry: TimelineEntry {
    let date: Date
    let value: [Watcher]
}

struct Provider: TimelineProvider {
    //let auth = Auth()
    let auth = Auth.shared
    
    @Query(sort: \Watcher.title) var items: [Watcher]
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), value: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), value: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let items = await getItems()
            print("Widget \(items.count)")
            //let value = "\(items.count)" // auth.demo() ?? "unknown"
            
            var value = "n/a"
            if let item = items.first,
               let accessToken = await Auth.shared.refresh() {
                let retrieved = await GoogleSheets.getValue(accessToken, item.spreadsheetId, item.sheetName, item.column, item.row)
                value = retrieved == "" ? value : retrieved
                print("widget value: \(value)")
            }
            
            var entries: [SimpleEntry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, value: items)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    @MainActor
    private func getItems() -> [Watcher] {
        do {
            let container = try ModelContainer(for: Watcher.self)
            let descriptor = FetchDescriptor<Watcher>()
            let items = try container.mainContext.fetch(descriptor)
            return items
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

struct WidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Grid(alignment:.leading) {
            ForEach(entry.value) { item in
                GridRow {
                    Text(item.title)
                    Text(item.value).foregroundStyle(item.color)
                }
            }
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    SimpleEntry(date: .now, value: [Watcher(title: "Demo", spreadsheetId: "1", spreadsheetName: "Sheet1", sheetName: "Sheet1", column: "A", row: 2)])
    SimpleEntry(date: .now, value: [Watcher(title: "Demo", spreadsheetId: "1", spreadsheetName: "Sheet1", sheetName: "Sheet1", column: "A", row: 2)])
}
