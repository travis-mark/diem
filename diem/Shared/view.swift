//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/7/23.

import Foundation
import WidgetKit
import SwiftUI
import Intents

func applyOrdinal( _ input: String, _ date: Date) -> String {
    do {
        let regex = try NSRegularExpression(pattern: "([A-Za-z]+)/([os])", options: [])
        let result = NSMutableString(string: input)
        
        regex.matches(in: input, range: NSRange(location: 0, length: input.utf16.count)).reversed().forEach({ match in
            let nsrange0 = match.range(at: 0)
            let nsrange1 = match.range(at: 1)
            let nsrange2 = match.range(at: 2)
            if let range1 = Range(nsrange1, in: input),
               let range2 = Range(nsrange2, in: input) {
                let match = input[range1]
                let type = input[range2]
                let replacement = type == "s"
                    ? string(from: date, format: String(match))
                    : string(from: date, format: String(match)).toOrdinal
                result.replaceCharacters(in: nsrange0, with: replacement)
            }
        })

        return result as String
    } catch {
        return input
    }
}

struct DateWidgetView: View {
    let date: Date
    let textLabel: String
    let textLabelBold: Bool
    let detailTextLabel: String
    let detailTextLabelBold: Bool
    
    var body: some View {
        VStack {
            if textLabelBold == true {
                Text(applyOrdinal(textLabel, date))
                    .fontWeight(.bold)
                    .widgetAccentable()
            } else {
                Text(applyOrdinal(textLabel, date))
            }
            if detailTextLabel.isEmpty == false {
                if detailTextLabelBold == true {
                    Text(applyOrdinal(detailTextLabel, date))
                        .fontWeight(.bold)
                        .widgetAccentable()
                } else {
                    Text(applyOrdinal(detailTextLabel, date))
                }
            }
        }
    }
}

struct DateView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMMM/s", textLabelBold: true, detailTextLabel: "d/s", detailTextLabelBold: false)
    }
}

struct DayView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "F/o", textLabelBold: true, detailTextLabel: "EEE/s", detailTextLabelBold: false)
    }
}

struct YearDayView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Day", textLabelBold: true, detailTextLabel: "D/s", detailTextLabelBold: false)
    }
}

struct YearWeekView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Week", textLabelBold: true, detailTextLabel: "ww/s", detailTextLabelBold: false)
    }
}

struct DateInlineView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMM/s d/s - F/o EEEE/s", textLabelBold: false, detailTextLabel: "", detailTextLabelBold: false)
    }
}


struct YearInlineView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "Day D/s - Week ww/s", textLabelBold: false, detailTextLabel: "", detailTextLabelBold: false)
    }
}

struct EverythingView: View {
    let date: Date
    var body: some View {
        DateWidgetView(date: date, textLabel: "MMM/s d/s - F/o EEEE/s", textLabelBold: true, detailTextLabel: "Day D/s - Week ww/s", detailTextLabelBold: false)
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
