import AppIntents
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
            Text(self.entry.value.isEmpty ? "item 0": self.entry.value).font(.caption).foregroundStyle(.secondary)
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

struct WidgetAlphaIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Person"
    
    @Parameter(title: "Value")
    var value: String?
    
    @Parameter(title: "First")
    var first: WatcherEntity?
}

struct WatcherEntity: AppEntity, Identifiable, Hashable {
    var id: String
    var title: String
    var value: String
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title): \(value)")
    }
    
    init(id: String, title: String, value: String) {
        self.id = id
        self.title = title
        self.value = value
    }
    
    init(watcher: Watcher) {
        self.id = "\(watcher.id)"
        self.title = watcher.title
        self.value = watcher.value
    }

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Watcher")
    static var defaultQuery = WatcherEntityQuery()
}

struct WatcherEntityQuery: EntityQuery, Sendable {
    func entities(for identifiers: [WatcherEntity.ID]) async throws -> [WatcherEntity] {
        return fetchProducts()
            .filter { identifiers.contains("\($0.id)") }
            .map(WatcherEntity.init)
    }

    func suggestedEntities() async throws -> [WatcherEntity] {
        return fetchProducts().map(WatcherEntity.init)
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
        return WidgetAlphaEntry(date: .now, value: "plh")
    }
    func snapshot(for configuration: WidgetAlphaIntent, in context: Context) async -> WidgetAlphaEntry {
        print("snapshot")
        return WidgetAlphaEntry(date: .now, value: "snap")
    }
    func timeline(for configuration: WidgetAlphaIntent, in context: Context) async -> Timeline<WidgetAlphaEntry> {
        let date = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let value = configuration.value ?? "edit me"
        let first = configuration.first?.title ?? "notitle"
        let entry = WidgetAlphaEntry(date: date, value: first)
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
    WidgetAlphaEntry(date: .now, value: "Hello")
    WidgetAlphaEntry(date: .now, value: "World")
}
