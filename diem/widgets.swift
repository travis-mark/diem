//  diem/widgets - widgets.swift
//  Created by Travis Luckenbaugh on 3/31/23.

// TODO: 2024-10-03 Do I need all of the individual phone widgets?
// TODO: 2024-10-03 Re-connect watch widgets

import WidgetKit
import SwiftUI
import Intents

let smallFamilies: [WidgetFamily] = {
#if os(iOS)
    return [.systemSmall]
#elseif os(watchOS)
    return [.accessoryCircular, .accessoryCorner]
#else
    return []
#endif
}()

struct DateWidget: Widget {
    let kind: String = "com.tl.diem.widget.date"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            DateView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies(smallFamilies)
    }
}

struct DayWidget: Widget {
    let kind: String = "com.tl.diem.widget.day"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            DayView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Day")
        .description("Shows Position in Month")
        .supportedFamilies(smallFamilies)
    }
}

struct YearDayWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearday"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            YearDayView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Day of Year")
        .description("Shows Day of Year")
        .supportedFamilies(smallFamilies)
    }
}

struct YearWeekWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearweek"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            YearWeekView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Week of Year")
        .description("Shows Week of Year")
        .supportedFamilies(smallFamilies)
    }
}

struct DateInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.dateInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            DateInlineView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies([.accessoryInline])
    }
}

struct YearInlineWidget: Widget {
    let kind: String = "com.tl.diem.widget.yearInline"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            YearInlineView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("YTD")
        .description("Shows Day and Week of Year")
        .supportedFamilies([.accessoryInline])
    }
}

struct EverythingWidget: Widget {
    let kind: String = "com.tl.diem.widget.everything"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            EverythingView(date: entry.date).unredacted().widgetBackground()
        }
        .configurationDisplayName("Today")
        .description("Shows Date Info")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct StackedWidget: Widget {
    let kind: String = "com.tl.diem.widget.stacked"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack {
                DateHWidgetView(date: entry.date, textLabel: "MMM/s", detailTextLabel: "d/s")
                DateHWidgetView(date: entry.date, textLabel: "F/o", detailTextLabel: "EEE/s")
                DateHWidgetView(date: entry.date, textLabel: "Day", detailTextLabel: "D/s")
                DateHWidgetView(date: entry.date, textLabel: "Week", detailTextLabel: "ww/s")
            }
            .unredacted()
            .widgetBackground()
        }
        .configurationDisplayName("Today")
        .description("Shows Date Info")
        .supportedFamilies([.systemSmall])
    }
}

extension View {
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.containerBackground(.background, for: .widget)
        } else {
            return self
        }
    }
}

@main struct DiemWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        DateWidget()
        DayWidget()
        YearDayWidget()
        YearWeekWidget()
        DateInlineWidget()
        YearInlineWidget()
        EverythingWidget()
        StackedWidget()
    }
}
