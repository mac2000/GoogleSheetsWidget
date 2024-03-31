import WidgetKit
import SwiftData
import SwiftUI
import Shared

struct WidgetAlphaEntry: TimelineEntry {
    let date: Date
    let value: String
}

struct WidgetAlphaView : View {
    var entry: WidgetAlphaEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text("item 0").font(.caption).foregroundStyle(.secondary)
            HStack {
                Text("2.4%").font(.title)
                Spacer()
            }
            Spacer()
            HStack {
                Text("1.2%")
                Text("item 1").font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text("1.2%")
                Text("item 1").font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text("1.2%")
                Text("item 1").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct WidgetAlphaProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetAlphaEntry {
        return WidgetAlphaEntry(date: .now, value: "Hello")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetAlphaEntry) -> Void) {
        let entry = WidgetAlphaEntry(date: .now, value: "Hello")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetAlphaEntry>) -> ()) {
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
            
            var entries: [WidgetAlphaEntry] = []
            
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = WidgetAlphaEntry(date: entryDate, value: "items")
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    @MainActor
    private func getItems() async -> [Watcher] {
        do {
            try? await Task.sleep(nanoseconds: 1_000_000)
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

struct WidgetAlpha: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WidgetAlpha", provider: WidgetAlphaProvider()) { entry in
            WidgetAlphaView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Alpha")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WidgetAlpha()
} timeline: {
    WidgetAlphaEntry(date: .now, value: "Hello")
    WidgetAlphaEntry(date: .now, value: "World")
}
