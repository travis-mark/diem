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
        return [IntentRecommendation(intent: DiemIntent(), description: "")]
    }
}

struct DateWidget: Widget {
    let kind: String = "com.tl.diem.widget.date"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            VStack {
                Text(string(from: entry.date, format: "MMMM"))
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "d"))
            }
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

struct DayWidget: Widget {
    let kind: String = "com.tl.diem.widget.day"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            VStack {
                Text(string(from: entry.date, format: "F").toOrdinal)
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "EEE"))
            }
        }
        .configurationDisplayName("Day")
        .description("Shows Position in Month")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

struct YearDayWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearday"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            VStack {
                Text("Day")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "D"))
            }
        }
        .configurationDisplayName("Day of Year")
        .description("Shows Day of Year")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

struct YearWeekWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearweek"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            VStack {
                Text("Week")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "ww"))
            }
        }
        .configurationDisplayName("Week of Year")
        .description("Shows Week of Year")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

struct EverythingWidget: Widget {
    let kind: String = "com.tl.diem.widget.everything"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemIntent.self, provider: DiemProvider()) { entry in
            VStack {
                Text("\(string(from: entry.date, format: "MMMM d")) - \(string(from: entry.date, format: "F EEEE").toOrdinalAll)")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text("\(string(from: entry.date, format: "'Day' D - 'Week' ww"))")
            }
        }
        .configurationDisplayName("Today")
        .description("Shows Date Info")
        .supportedFamilies([.accessoryRectangular])
    }
}

@main struct DiemWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        DateWidget()
        DayWidget()
        YearDayWidget()
        YearWeekWidget()
    }
}
