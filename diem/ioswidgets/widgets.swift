//  diem/iOS - widgets.swift
//  Created by Travis Luckenbaugh on 4/9/23.

import WidgetKit
import SwiftUI

struct DayWidget: Widget {
    let kind: String = "com.tl.diem.widget.day"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            DayView(date: entry.date)
        }
        .configurationDisplayName("Day")
        .description("Shows Position in Month")
//        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

@main struct DiemBundle: WidgetBundle {
    var body: some Widget {
        DayWidget()
    }
}


struct DiemWidget_Previews: PreviewProvider {
    static var previews: some View {
        DayView(date: Date())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


