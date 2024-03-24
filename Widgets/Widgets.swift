import WidgetKit
import SwiftUI
import SwiftData
import Shared

struct SimpleEntry: TimelineEntry {
    let date: Date
    let value: String
}

struct Provider: TimelineProvider {
    //let auth = Auth()
    let auth = Auth.shared
    
    @Query(sort: \Watcher.title) var items: [Watcher]
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), value: "N/A")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), value: "N/A")
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
                let entry = SimpleEntry(date: entryDate, value: value)
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
        VStack(spacing:8) {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Value:")
            Text(entry.value)
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
    SimpleEntry(date: .now, value: "A")
    SimpleEntry(date: .now, value: "B")
}
