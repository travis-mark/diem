//  diem - lib.swift
//  Created by Travis Luckenbaugh on 3/30/23.

import Foundation

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
