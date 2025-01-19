//  diem/iOS - WidgetPreviewView.swift
//  Created by Travis Luckenbaugh on 1/6/25.

import SwiftUI

struct WidgetPreviewLandscapeView: View {
    var date: Date
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("Small Widgets").bold()
                Grid {
                    GridRow {
                        DateView(date: date).modifier(WidgetBoxModifier())
                        DayView(date: date).modifier(WidgetBoxModifier())
                    }
                    GridRow {
                        YearDayView(date: date).modifier(WidgetBoxModifier())
                        YearWeekView(date: date).modifier(WidgetBoxModifier())
                    }
                }
            }
            VStack {
                VStack {
                    Text("Inline Widgets").bold()
                    DateInlineView(date: date).modifier(WidgetBoxModifier())
                }
                VStack {
                    Text("Large Widgets").bold()
                    EverythingView(date: date).modifier(WidgetBoxModifier())
                }
            }
            VStack {
                Text("Adding Widgets on Apple Watch").bold()
                Text("Long-press in the center of the watch. Tap the (Edit) button in the bottom right corner and swipe right to edit complications. Select the complications to replace and scroll to find the Diem widget you want to add.")
            }
        }
        .padding(20)
    }
}

struct WidgetPreviewPortraitView: View {
    var date: Date
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Small Widgets").bold()
                HStack {
                    DateView(date: date).modifier(WidgetBoxModifier())
                    DayView(date: date).modifier(WidgetBoxModifier())
                    YearDayView(date: date).modifier(WidgetBoxModifier())
                    YearWeekView(date: date).modifier(WidgetBoxModifier())
                }
            }
            VStack {
                VStack {
                    Text("Inline Widgets").bold()
                    DateInlineView(date: date).modifier(WidgetBoxModifier())
                }
                VStack {
                    Text("Large Widgets").bold()
                    EverythingView(date: date).modifier(WidgetBoxModifier())
                }
            }
            VStack(spacing: 4) {
                Text("Adding Widgets on Apple Watch").bold()
                Text("Long-press in the center of the watch. Tap the (Edit) button in the bottom right corner and swipe right to edit complications. Select the complications to replace and scroll to find the Diem widget you want to add.")
            }
        }
        .padding(20)
    }
}

struct WidgetPreviewView: View {
    @State private var date = Date()
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if geometry.size.width > geometry.size.height {
                    WidgetPreviewLandscapeView(date: date)
                } else {
                    WidgetPreviewPortraitView(date: date)
                }
            }
            Spacer()
            DateWidgetView(date: date, textLabel: "D/d", detailTextLabel: "")
            DatePickerView(date: $date)
        }
        .onAppear {
            date = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            date = Date()
        }
    }
}
