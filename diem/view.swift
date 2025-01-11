//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/7/23.

import Foundation
import WidgetKit
import SwiftUI
import Intents

struct DateWidgetView: View {
    let date: Date
    let textLabel: String
    let detailTextLabel: String
    
    var body: some View {
        VStack {
            Text(evalDateFormat(textLabel, date))
                .fontWeight(.bold)
                .widgetAccentable()
            if detailTextLabel.isEmpty == false {
                Text(evalDateFormat(detailTextLabel, date)).multilineTextAlignment(.center)
            }
        }
    }
}

struct DateHWidgetView: View {
    let date: Date
    let textLabel: String
    let detailTextLabel: String
    
    var body: some View {
        HStack {
            Text(evalDateFormat(textLabel, date))
                .fontWeight(.bold)
                .widgetAccentable()
            if detailTextLabel.isEmpty == false {
                Text(evalDateFormat(detailTextLabel, date))
            }
        }
    }
}

struct DateView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMM/s", detailTextLabel: "d/s")
    }
}

struct DayView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "F/o", detailTextLabel: "EEE/s")
    }
}

struct YearDayView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Day", detailTextLabel: "D/s")
    }
}

struct YearWeekView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Week", detailTextLabel: "ww/s")
    }
}

struct DateInlineView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMM/s d/s - F/o EEEE/s", detailTextLabel: "")
    }
}


struct YearInlineView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Day D/s - Week ww/s", detailTextLabel: "")
    }
}

struct EverythingView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMM/s d/s - F/o EEE/s", detailTextLabel: "Day D/s - Week ww/s\nD/d")
    }
}

struct StackedView: View {
    let date: Date
    var body: some View {
        VStack {
            DateWidgetView(date: date, textLabel: "MMM/s", detailTextLabel: "d/s")
            DateWidgetView(date: date, textLabel: "F/o", detailTextLabel: "EEE/s")
            DateWidgetView(date: date, textLabel: "Day", detailTextLabel: "D/s")
            DateWidgetView(date: date, textLabel: "Week", detailTextLabel: "ww/s")
        }
    }
}

struct WidgetBoxModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}
