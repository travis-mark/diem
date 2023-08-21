//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/9/23.

import WidgetKit

struct DiemEntry: TimelineEntry {
    let date: Date
    let textLabel: String
    let textLabelBold: Bool
    let detailTextLabel: String
    let detailTextLabelBold: Bool
    
    init(date: Date, intent: DiemDateFormatterIntent) {
        self.date = date
        self.textLabel = intent.textLabel ?? ""
        self.textLabelBold = intent.textLabelBold?.boolValue == true
        self.detailTextLabel = intent.detailTextLabel ?? ""
        self.detailTextLabelBold = intent.detailTextLabelBold?.boolValue == true
    }
    
    init(date: Date, textLabel: String = "", textLabelBold: Bool = false, detailTextLabel: String = "", detailTextLabelBold: Bool = false) {
        self.date = date
        self.textLabel = textLabel
        self.textLabelBold = textLabelBold
        self.detailTextLabel = detailTextLabel
        self.detailTextLabelBold = detailTextLabelBold
    }
}

extension DiemDateFormatterIntent {
    convenience init(title: String? = nil, textLabel: String? = nil, textLabelBold: NSNumber? = nil, detailTextLabel: String? = nil, detailTextLabelBold: NSNumber? = nil) {
        self.init()
        self.title = title
        self.textLabel = textLabel
        self.textLabelBold = textLabelBold
        self.detailTextLabel = detailTextLabel
        self.detailTextLabelBold = detailTextLabelBold
    }
}

let dateIntent = DiemDateFormatterIntent(title: "Date", textLabel: "MMM/s", textLabelBold: true, detailTextLabel: "d/s", detailTextLabelBold: false)
let dayIntent = DiemDateFormatterIntent(title: "Day of Week", textLabel: "F/o", textLabelBold: true, detailTextLabel: "EEE/s", detailTextLabelBold: false)
let yearDayIntent = DiemDateFormatterIntent(title: "Day of Year", textLabel: "Day", textLabelBold: true, detailTextLabel: "D/s", detailTextLabelBold: false)
let yearWeekIntent = DiemDateFormatterIntent(title: "Week of Year", textLabel: "Week", textLabelBold: true, detailTextLabel: "ww/s", detailTextLabelBold: false)
let dateInlineIntent = DiemDateFormatterIntent(title: "Long Date", textLabel: "MMM/s d/s - F/o EEEE/s", textLabelBold: false, detailTextLabel: "", detailTextLabelBold: false)
let yearInlineIntent = DiemDateFormatterIntent(title: "Day and Week of Year", textLabel: "Day D/s - Week ww/s", textLabelBold: false, detailTextLabel: "", detailTextLabelBold: false)
let everythingIntent = DiemDateFormatterIntent(title: "Everything", textLabel: "MMM/s d/s - F/o EEEE/s", textLabelBold: true, detailTextLabel: "Day D/s - Week ww/s", detailTextLabelBold: false)
let allIntents = [dateIntent, dayIntent, yearDayIntent, yearWeekIntent, dateInlineIntent, yearInlineIntent, everythingIntent]

struct DiemProvider: IntentTimelineProvider {
    func recommendations() -> [IntentRecommendation<DiemDateFormatterIntent>] {
        return allIntents.map({
            IntentRecommendation(intent: $0, description: $0.title ?? "--")
        })
    }
    
    func getSnapshot(for intent: DiemDateFormatterIntent, in context: Context, completion: @escaping (DiemEntry) -> Void) {
        let entry = DiemEntry(date: Date(), intent: intent)
        completion(entry)
    }
    
    func getTimeline(for intent: DiemDateFormatterIntent, in context: Context, completion: @escaping (Timeline<DiemEntry>) -> Void) {
        var entries: [DiemEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DiemEntry(date: entryDate, intent: intent)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> DiemEntry {
        DiemEntry(date: Date(), textLabel: "TODAY")
    }
}
