//
//  widgets.swift
//  widgets
//
//  Created by Travis Luckenbaugh on 3/31/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return [
            IntentRecommendation(intent: ConfigurationIntent(), description: "Day of Year")
        ]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct widgetsEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
        
    var body: some View {
        switch family {
        case .systemSmall: Text("systemSmall")
        case .systemMedium: Text("systemMedium")
        case .systemLarge: Text("systemLarge")
        case .systemExtraLarge: Text("systemExtraLarge")
        case .accessoryCircular:
            VStack {
                Text("Day")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "D"))
            }
        case .accessoryRectangular:
            VStack {
                Text("\(string(from: entry.date, format: "MMMM d")) - \(string(from: entry.date, format: "F EEEE").toOrdinalAll)")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text("\(string(from: entry.date, format: "D 'Day -' ww 'Week").toOrdinalAll)")
            }
        case .accessoryInline:
            Text("\(string(from: entry.date, format: "'Day' D"))")
        default: Text("default")
        }
    }
}

@main struct widgets: Widget {
    let kind: String = "widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Day of Year")
        .description("")
    }
}

struct widgets_Previews: PreviewProvider {
    static var previews: some View {
        widgetsEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
