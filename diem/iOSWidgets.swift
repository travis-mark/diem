//  diem - iOSWidgets.swift
//  Created by Travis Luckenbaugh on 3/31/23.

import WidgetKit
import SwiftUI
import Intents

extension View {
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.containerBackground(.background, for: .widget)
        } else {
            return self
        }
    }
}

struct StackedWidget: Widget {
    let kind: String = "com.tl.diem.widget.stacked"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            VStack(alignment: .leading) {
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

@main struct DiemWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        StackedWidget()
    }
}
