//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/7/23.

import Foundation
import WidgetKit
import SwiftUI
import Intents

struct DateView: View {
    let date: Date
    var body: some View {
        VStack {
            Text(string(from: date, format: "MMMM"))
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "d"))
        }
    }
}

struct DayView: View {
    let date: Date
    var body: some View {
        VStack {
            Text(string(from: date, format: "F").toOrdinal)
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "EEE"))
        }
    }
}

struct YearDayView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("Day")
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "D"))
        }
    }
}

struct YearWeekView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("Week")
                .fontWeight(.bold)
                .widgetAccentable()
            Text(string(from: date, format: "ww"))
        }
    }
}

struct DateInlineView: View {
    let date: Date
    var body: some View {
        Text("\(string(from: date, format: "MMM d")) - \(string(from: date, format: "F EEEE").toOrdinalAll)")
    }
}


struct YearInlineView: View {
    let date: Date
    var body: some View {
        Text(string(from: date, format: "'Day' D - 'Week' ww"))
    }
}

struct EverythingView: View {
    let date: Date
    var body: some View {
        VStack {
            Text("\(string(from: date, format: "MMM d")) - \(string(from: date, format: "F EEEE").toOrdinalAll)")
                .fontWeight(.bold)
                .widgetAccentable()
            Text("\(string(from: date, format: "'Day' D - 'Week' ww"))")
        }
    }
}

struct WidgetBoxModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.lightGray))
            .cornerRadius(8)
    }
}
