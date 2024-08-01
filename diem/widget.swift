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
        
        // Beginning of each hour for 5 hours
        let calendar = Calendar.current
        let date = Date()
        for hour in 1 ... 5 {
            let entryDate = calendar.date(byAdding: .hour, value: hour, to: date)!
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
