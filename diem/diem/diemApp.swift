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

let ordinalFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .ordinal
    return nf
}()

extension String {
    /// If string is a parse-able integer, return it's localized ordinal representation
    /// Otherwise return nil
    var toOrdinal: String? {
        guard let parsed = Int(self) else { return nil }
        let number = NSNumber(value: parsed)
        return ordinalFormatter.string(from: number)
    }
    
    /// Convert numbers inside string to ordinal
    var toOrdinalAll: String {
        return self
            .split(separator: /\s+/)
            .map({ String($0) })
            .map({ $0.toOrdinal ?? $0 })
            .joined(separator: " ")
    }
}

struct PrimaryView: View {
    let date = Date()
    var body: some View {
        VStack {
            Text("\(string(from: date, format: "MMMM dd '-' F EEEE").toOrdinalAll)")
            Text("\(string(from: date, format: "D 'Day -' ww 'Week").toOrdinalAll)")
            Text("\(string(from: date, format: "YYYY GG"))")
            Text("")
            Text("\(string(from: date, format: "hh:mm:ss a"))")
            Text("\(string(from: date, format: "vvvv (z)XXX"))")
        }
    }
}

struct EverythingView: View {
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

struct ContentView: View {
    var body: some View {
        TabView {
            PrimaryView().tabItem {
                Image(systemName: "calendar.badge.clock")
                Text("Main")
            }
            EverythingView().tabItem {
                Image(systemName: "clock.badge.questionmark.fill")
                Text("Debug")
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
