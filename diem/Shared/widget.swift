//  diem - view.swift
//  Created by Travis Luckenbaugh on 4/9/23.

import WidgetKit

struct DiemEntry: TimelineEntry {
    let date: Date
}

struct DiemProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (DiemEntry) -> Void) {
        let entry = DiemEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiemEntry>) -> Void) {
        var entries: [DiemEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DiemEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> DiemEntry {
        DiemEntry(date: Date())
    }
}
