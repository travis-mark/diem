//  diem/iOS - widgets.swift
//  Created by Travis Luckenbaugh on 4/9/23.

import WidgetKit
import SwiftUI

struct EverythingWidget: Widget {
    let kind: String = "com.tl.diem.widget.everything"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiemProvider()) { entry in
            EverythingView(date: entry.date)
        }
        .configurationDisplayName("Today")
        .description("Shows Date Info")
        .supportedFamilies([.systemSmall])
    }
}

@main struct DiemBundle: WidgetBundle {
    var body: some Widget {
        EverythingWidget()
    }
}


struct DiemWidget_Previews: PreviewProvider {
    static var previews: some View {
        EverythingView(date: Date())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


