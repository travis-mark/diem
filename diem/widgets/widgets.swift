//  diem/watchOS - widgets.swift
//  Created by Travis Luckenbaugh on 3/31/23.

import WidgetKit
import SwiftUI
import Intents

struct DateFormatterWidget: Widget {
    let kind: String = "com.tl.diem.widget.dateformatter"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DiemDateFormatterIntent.self, provider: DiemProvider()) { entry in
            DateWidgetView(entry: entry).unredacted()
        }
        .configurationDisplayName("Date")
        .description("Shows Date")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

@main struct DiemWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        DateFormatterWidget()
    }
}
