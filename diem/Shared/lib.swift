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

func evalDateFormat( _ input: String, _ date: Date) -> String {
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
