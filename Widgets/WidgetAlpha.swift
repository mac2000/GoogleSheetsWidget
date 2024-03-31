import AppIntents
import WidgetKit
import SwiftData
import SwiftUI
import Shared

struct WidgetAlphaEntry: TimelineEntry {
    let date: Date
    let main: Watcher?
    let row1: Watcher?
    let row2: Watcher?
    let row3: Watcher?
    
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
                if let cell = self.entry.main {
                    Text(cell.title).font(.caption).foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    HStack {
                        Text(cell.value).font(.title).foregroundStyle(cell.color)
                        Spacer()
                    }
                    Spacer()
                }
                if let cell = self.entry.row1 {
                    HStack {
                        Text(cell.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(cell.value)
                            .foregroundStyle(cell.color)
                    }
                }
                if let cell = self.entry.row2 {
                    HStack {
                        Text(cell.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(cell.value)
                            .foregroundStyle(cell.color)
                    }
                }
                if let cell = self.entry.row3 {
                    HStack {
                        Text(cell.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(cell.value)
                            .foregroundStyle(cell.color)
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
}

struct WatcherEntity: AppEntity, Identifiable, Hashable {
    var id: String
    var watcher: Watcher?
    
    var isEmpty: Bool {
        return id.isEmpty || watcher == nil
    }
    
    var displayTitle: LocalizedStringResource {
        return isEmpty
        ? "Choose"
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
        var items = fetch()
            .filter { identifiers.contains("\($0.id)") }
            .map(WatcherEntity.init)
        
        items.insert(WatcherEntity(watcher: nil), at: 0)
        return items
    }
    
    func suggestedEntities() async throws -> [WatcherEntity] {
        var items = fetch()
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
    
    private func fetch() -> [Watcher] {
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
        
        return WidgetAlphaEntry(date: .now, main: Watcher.example1, row1: Watcher.example2, row2: Watcher.example3, row3: nil)
    }
    func snapshot(for configuration: WidgetAlphaIntent, in context: Context) async -> WidgetAlphaEntry {
        print("snapshot")
        return WidgetAlphaEntry(date: .now, main: Watcher.example1, row1: Watcher.example2, row2: Watcher.example3, row3: nil)
    }
    func timeline(for configuration: WidgetAlphaIntent, in context: Context) async -> Timeline<WidgetAlphaEntry> {
        let items = await refresh()
        let date = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let entry = WidgetAlphaEntry(date: date, main: configuration.main?.watcher, row1: configuration.row1?.watcher, row2: configuration.row2?.watcher, row3: configuration.row3?.watcher)
        print("timeline")
        return Timeline(entries: [entry], policy: .atEnd)
    }
    private static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Watcher.self)
        } catch {
            fatalError("\(error)")
        }
    }()
    
    private func fetch() -> [Watcher] {
        do {
            let context = ModelContext(Self.container)
            let items = try context.fetch(FetchDescriptor<Watcher>())
            return items
        } catch {
            print("Error fetching products: \(error)")
            return []
        }
    }
    
    private func refresh() async -> [Watcher] {
        var items = fetch()
        guard let accessToken = await Auth.shared.refresh() else {
            return items
        }
        for item in items {
            let value = await GoogleSheets.getValue(accessToken, item.spreadsheetId, item.sheetName, item.column, item.row)
            if value != "" && value != "Loading..." {
                item.value = value
            }
        }
        return items
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
    WidgetAlphaEntry(date: .now, main: Watcher.example1, row1: Watcher.example2, row2: Watcher.example3, row3: nil)
}
