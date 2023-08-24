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
        
        // Beginning of each day for 5 days
        let calendar = Calendar.current
        let todayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        for day in 1 ... 5 {
            let entryDate = calendar.date(byAdding: .day, value: day, to: todayStart)!
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
