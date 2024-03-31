import AppIntents
import WidgetKit
import SwiftData
import SwiftUI
import Shared

struct WidgetAlphaCell {
    let title: String
    let value: String
}

struct WidgetAlphaEntry: TimelineEntry {
    let date: Date
    let main: WidgetAlphaCell?
    let row1: WidgetAlphaCell?
    let row2: WidgetAlphaCell?
    let row3: WidgetAlphaCell?
    
    var isEmpty: Bool {
        return main == nil && row1 == nil && row2 == nil && row3 == nil
    }
}

struct WidgetAlphaView : View {
    var entry: WidgetAlphaEntry
    var body: some View {
        VStack(alignment: .leading) {
            if self.entry.isEmpty {
                Text("Edit widget")
            } else {
                if self.entry.main != nil {
                    Text(self.entry.main!.title).font(.caption).foregroundStyle(.secondary)
                    HStack {
                        Text(self.entry.main!.value).font(.title)
                        Spacer()
                    }
                    Spacer()
                }
                if self.entry.row1 != nil {
                    HStack {
                        Text(self.entry.row1!.value)
                        Text(self.entry.row1!.title).font(.caption).foregroundStyle(.secondary)
                    }
                }
                if self.entry.row2 != nil {
                    HStack {
                        Text(self.entry.row2!.value)
                        Text(self.entry.row2!.title).font(.caption).foregroundStyle(.secondary)
                    }
                }
                if self.entry.row3 != nil {
                    HStack {
                        Text(self.entry.row3!.value)
                        Text(self.entry.row3!.title).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct WidgetAlphaIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Person"
    
    @Parameter(title: "Main")
    var main: WatcherEntity?
    
    @Parameter(title: "Row 1")
    var row1: WatcherEntity?
    
    @Parameter(title: "Row 2")
    var row2: WatcherEntity?
    
    @Parameter(title: "Row 3")
    var row3: WatcherEntity?
    
    var mainCell: WidgetAlphaCell? {
        if let item = main,
           let watcher = item.watcher {
            return WidgetAlphaCell(title: watcher.title, value: watcher.value)
        }
        return nil
    }
    var row1Cell: WidgetAlphaCell? {
        if let item = row1,
           let watcher = item.watcher {
            return WidgetAlphaCell(title: watcher.title, value: watcher.value)
        }
        return nil
    }
    var row2Cell: WidgetAlphaCell? {
        if let item = row2,
           let watcher = item.watcher {
            return WidgetAlphaCell(title: watcher.title, value: watcher.value)
        }
        return nil
    }
    var row3Cell: WidgetAlphaCell? {
        if let item = row3,
           let watcher = item.watcher {
            return WidgetAlphaCell(title: watcher.title, value: watcher.value)
        }
        return nil
    }
}

struct WatcherEntity: AppEntity, Identifiable, Hashable {
    var id: String
    var watcher: Watcher?
    
    var isEmpty: Bool {
        return id.isEmpty || watcher == nil
    }
    
    var displayTitle: LocalizedStringResource {
        return isEmpty
        ? "None"
        :"\(watcher!.title): \(watcher!.value)"
    }
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: displayTitle)
    }
    
    init(watcher: Watcher?) {
        if let watcher = watcher {
            self.id = "\(watcher.id)"
            self.watcher = watcher
        } else {
            self.id = ""
            self.watcher = nil
        }
    }

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Watcher")
    static var defaultQuery = WatcherEntityQuery()
}

struct WatcherEntityQuery: EntityQuery, Sendable {
    func entities(for identifiers: [WatcherEntity.ID]) async throws -> [WatcherEntity] {
        var items = fetchProducts()
            .filter { identifiers.contains("\($0.id)") }
            .map(WatcherEntity.init)
            
        items.insert(WatcherEntity(watcher: nil), at: 0)
        return items
    }

    func suggestedEntities() async throws -> [WatcherEntity] {
        var items = fetchProducts()
            .map(WatcherEntity.init)
            
        items.insert(WatcherEntity(watcher: nil), at: 0)
        return items
    }
    
    private static let container: ModelContainer = {
            do {
                return try ModelContainer(for: Watcher.self)
            } catch {
                fatalError("\(error)")
            }
        }()
    
    private func fetchProducts() -> [Watcher] {
            do {
                let context = ModelContext(Self.container)
                let items = try context.fetch(FetchDescriptor<Watcher>())
                return items
            } catch {
                print("Error fetching products: \(error)")
                return []
            }
        }
}

struct WidgetAlphaProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) ->  WidgetAlphaEntry {
        print("placeholder")
        return WidgetAlphaEntry(date: .now, main: WidgetAlphaCell(title: "sample", value: "23.4%"), row1: WidgetAlphaCell(title: "foo", value: "4"), row2: WidgetAlphaCell(title: "bar", value: "2"), row3: nil)
    }
    func snapshot(for configuration: WidgetAlphaIntent, in context: Context) async -> WidgetAlphaEntry {
        print("snapshot")
        return WidgetAlphaEntry(date: .now, main: WidgetAlphaCell(title: "sample", value: "23.4%"), row1: WidgetAlphaCell(title: "foo", value: "4"), row2: WidgetAlphaCell(title: "bar", value: "2"), row3: nil)
    }
    func timeline(for configuration: WidgetAlphaIntent, in context: Context) async -> Timeline<WidgetAlphaEntry> {
        let date = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let value = configuration.main?.watcher?.title ?? "notitle"
        let main = configuration.mainCell
        
        let entry = WidgetAlphaEntry(date: date, main: configuration.mainCell, row1: configuration.row1Cell, row2: configuration.row2Cell, row3: configuration.row3Cell)
        print("timeline")
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct WidgetAlpha: Widget {
    let kind: String = "WidgetAlpha"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "WidgetAlpha", intent: WidgetAlphaIntent.self, provider: WidgetAlphaProvider()) { entry in
            WidgetAlphaView(entry: entry)
        }
        .configurationDisplayName("Alpha")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WidgetAlpha()
} timeline: {
    WidgetAlphaEntry(date: .now, main: WidgetAlphaCell(title: "sample", value: "23.4%"), row1: WidgetAlphaCell(title: "foo", value: "4"), row2: WidgetAlphaCell(title: "bar", value: "2"), row3: nil)
}
