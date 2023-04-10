//  diem/watchOS - widgets.swift
//  Created by Travis Luckenbaugh on 3/31/23.

import WidgetKit
import SwiftUI
import Intents

struct DateWidget: Widget {
    let kind: String = "com.tl.diem.widget.date"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            DateView(date: entry.date)
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
            DayView(date: entry.date)
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
            YearDayView(date: entry.date)
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
            YearWeekView(date: entry.date)
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
            DateInlineView(date: entry.date)
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
            YearInlineView(date: entry.date)
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
            EverythingView(date: entry.date)
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
        YearInlineWidget()
        EverythingWidget()
    }
}
