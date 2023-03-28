//
//  diemApp.swift
//  diem
//
//  Created by Travis Luckenbaugh on 3/26/23.
//

import SwiftUI

var formatters = [String:DateFormatter]()

func string(from date: Date, format: String) -> String {
    if let df = formatters[format] {
        return df.string(from: date)
    } else {
        let df = DateFormatter()
        df.dateFormat = format
        formatters[format] = df
        return df.string(from: date)
    }
}

struct ContentView: View {
    let data = [
        ("Era", "GGGG"),
        ("Year", "YYYY"),
        ("Quarter", "QQQ"),
        ("Month", "MMMM"),
        ("Week (of Year)", "ww"),
        ("Week (of Month)", "W"),
        ("Day (of Year)", "D"),
        ("Day (of Month)", "d"),
        ("Day (of Week in Month)", "F"),
        ("Day (Julian)", "g"),
        ("Weekday", "EEEE"),
        ("Weekday (number)", "e"),
        ("Hour (1-12)", "hh"),
        ("Hour (0-23)", "HH"),
        ("Minutes", "mm"),
        ("Seconds", "ss"),
        ("Seconds (fractional)", "SSS"),
        ("Period", "a"),
        ("Milliseconds (of day)", "A"),
        ("Time Zone (short)", "zzz"),
        ("Time Zone (long)", "vvvv"),
        ("Time Zone (offset)", "XXXXX"),
    ]
    let date = Date()
    var body: some View {
        List {
            ForEach(data, id: \.1) { item in
                HStack() {
                    Text(item.0)
                        .font(.headline)
                    Spacer()
                    Text(string(from: date, format: item.1))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@main struct diemApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
