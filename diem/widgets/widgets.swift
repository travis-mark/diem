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
}

struct DiemProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (DiemEntry) -> Void) {
        let entry = DiemEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiemEntry>) -> Void) {
        var entries: [DiemEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DiemEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> DiemEntry {
        DiemEntry(date: Date())
    }
}

struct DateWidget: Widget {
    let kind: String = "com.tl.diem.widget.date"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack {
                Text(string(from: entry.date, format: "MMMM"))
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "d"))
            }
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct DayWidget: Widget {
    let kind: String = "com.tl.diem.widget.day"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack {
                Text(string(from: entry.date, format: "F").toOrdinal)
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "EEE"))
            }
        }
        .configurationDisplayName("Day")
        .description("Shows Position in Month")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct YearDayWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearday"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack {
                Text("Day")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "D"))
            }
        }
        .configurationDisplayName("Day of Year")
        .description("Shows Day of Year")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct YearWeekWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearweek"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack {
                Text("Week")
                    .fontWeight(.bold)
                    .widgetAccentable()
                Text(string(from: entry.date, format: "ww"))
            }
        }
        .configurationDisplayName("Week of Year")
        .description("Shows Week of Year")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct DateInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.dateInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            Text(string(from: entry.date, format: "MMMM d"))
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies([.accessoryInline])
    }
}

struct DayInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.dayInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            Text(string(from: entry.date, format: "F EEEE").toOrdinalAll)
        }
        .configurationDisplayName("Day")
        .description("Shows Position in Month")
        .supportedFamilies([.accessoryInline])
    }
}

struct YearDayInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearDayInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            Text(string(from: entry.date, format: "'Day' D"))
        }
        .configurationDisplayName("Day of Year")
        .description("Shows Day of Year")
        .supportedFamilies([.accessoryInline])
    }
}

struct YearWeekInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearWeekInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            Text(string(from: entry.date, format: "'Week' ww"))
        }
        .configurationDisplayName("Week of Year")
        .description("Shows Week of Year")
        .supportedFamilies([.accessoryInline])
    }
}

struct EverythingWidget: Widget {
    let kind: String = "com.tl.diem.widget.everything"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
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
        DateInlineWidget()
        DayInlineWidget()
        YearDayInlineWidget()
        YearWeekInlineWidget()
        EverythingWidget()
    }
}
