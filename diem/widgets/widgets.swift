//
//  widgets.swift
//  widgets
//
//  Created by Travis Luckenbaugh on 3/31/23.
//

import WidgetKit
import SwiftUI
import Intents

struct DiemEntry: TimelineEntry {
    let date: Date
    let configuration: DiemIntent
}

let defaultDiem = "MMMM d"

struct DiemProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> DiemEntry {
        DiemEntry(date: Date(), configuration: DiemIntent())
    }

    func getSnapshot(for configuration: DiemIntent, in context: Context, completion: @escaping (DiemEntry) -> ()) {
        let entry = DiemEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: DiemIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DiemEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DiemEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func recommendations() -> [IntentRecommendation<DiemIntent>] {
        let data = [
            ("MMMM d", "Date", true),
            ("F EEEE", "Day", true),
            ("'Day' D", "Year Day", false),
            ("'Week' ww", "Year Week", false)
        ]
        return data.map({
            let intent = DiemIntent()
            intent.format = $0.0
            intent.useOrdinal = NSNumber(value: $0.2)
            return IntentRecommendation(intent: intent, description: $0.1)
        })
    }
}


struct widgetsEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: DiemEntry
        
    var body: some View {
        let format = entry.configuration.format ?? defaultDiem
        switch family {
        case .systemSmall: Text("systemSmall")
        case .systemMedium: Text("systemMedium")
        case .systemLarge: Text("systemLarge")
        case .systemExtraLarge: Text("systemExtraLarge")
        case .accessoryCircular:
            let parts = format.split(separator:" ").map({
                entry.configuration.useOrdinal?.boolValue ?? false
                ? String($0).toOrdinalAll
                : String($0)
            })
            VStack {
                Text(string(from: entry.date, format: parts[0]))
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: parts[1]))
            }
        case .accessoryRectangular:
            VStack {
                Text("\(string(from: entry.date, format: "MMMM d")) - \(string(from: entry.date, format: "F EEEE").toOrdinalAll)")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text("\(string(from: entry.date, format: "D 'Day -' ww 'Week").toOrdinalAll)")
            }
        case .accessoryInline, .accessoryCorner:
            Text("\(string(from: entry.date, format: format))")
        default: Text("default")
        }
    }
}

@main struct widgets: Widget {
    let kind: String = "widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            widgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Day of Year")
        .description("")
    }
}

struct widgets_Previews: PreviewProvider {
    static var previews: some View {
        widgetsEntryView(entry: DiemEntry(date: Date(), configuration: DiemIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
