//  diem - lib.swift
//  Created by Travis Luckenbaugh on 3/30/23.

import Foundation

var dateFormatters = [String:DateFormatter]()

private func string(from date: Date, format: String) -> String {
    if let df = dateFormatters[format] {
        return df.string(from: date)
    } else {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone.current
        dateFormatters[format] = df
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
    var toOrdinal: String {
        guard let parsed = Int(self) else { return self }
        let number = NSNumber(value: parsed)
        return ordinalFormatter.string(from: number) ?? self
    }
    
    /// Convert numbers inside string to ordinal
    var toOrdinalAll: String {
        return self
            .split(separator: /\s+/)
            .map({ String($0) })
            .map({ $0.toOrdinal })
            .joined(separator: " ")
    }
}

func dateDiff( _ start: Date, _ end: Date, _ unit: Calendar.Component) -> Int? {
    return Calendar.current.dateComponents([.day], from: start, to: end).day
}

func dateDiffFormatted( _ start: Date, _ end: Date, _ unit: Calendar.Component) -> String {
    guard let dayDiff = dateDiff(start, end, .day) else { return "No Calendar" }
    if dayDiff == 0 { return "Today" }
    if dayDiff == 1 { return "1 day ago" }
    if dayDiff > 0 { return "\(dayDiff) days ago" }
    if dayDiff == -1  { return "1 day from now" }
    else  { return "\(-dayDiff) days from now" }
}

func evalDateFormat( _ input: String, _ date: Date) -> String {
    do {
        let regex = try NSRegularExpression(pattern: "([A-Za-z]+)/([dos])", options: [])
        let result = NSMutableString(string: input)
        
        regex.matches(in: input, range: NSRange(location: 0, length: input.utf16.count)).reversed().forEach({ match in
            let nsrange0 = match.range(at: 0)
            let nsrange1 = match.range(at: 1)
            let nsrange2 = match.range(at: 2)
            if let range1 = Range(nsrange1, in: input),
               let range2 = Range(nsrange2, in: input) {
                let match = input[range1]
                let type = input[range2]
                let replacement: String = {
                    switch type {
                    case "d":
                        return dateDiffFormatted(date, Date(), .day)
                    case "s":
                        return string(from: date, format: String(match))
                    case "o":
                        return string(from: date, format: String(match)).toOrdinal
                    default:
                        return String(type)
                    }
                }()
                result.replaceCharacters(in: nsrange0, with: replacement)
            }
        })

        return result as String
    } catch {
        return input
    }
}
