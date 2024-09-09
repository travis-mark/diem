//  diem/iOS - Date.swift
//  Created by Travis Luckenbaugh on 9/8/24.

import Foundation

fileprivate let dateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "EEE MMM d"
    return f
}()

fileprivate let timeFormatter = {
    let f = DateFormatter()
    f.dateStyle = .none
    f.timeStyle = .short
    return f
}()

func formatDateRange(_ startDate: Date?, _ endDate: Date?, isAllDay: Bool = false) -> String {
    guard let startDate else { return "--" }
    guard let endDate else { return "--" }
    let formattedStartDate = dateFormatter.string(from: startDate)
    let formattedEndDate = dateFormatter.string(from: endDate)
    if isAllDay {
        if (formattedStartDate == formattedEndDate) {
            return formattedStartDate
        } else {
            return "\(formattedStartDate) - \(formattedEndDate)"
        }
    } else {
        let formattedStartTime = timeFormatter.string(from: startDate)
        let formattedEndTime = timeFormatter.string(from: endDate)
        if (formattedStartDate == formattedEndDate) {
            if (formattedStartTime == formattedEndTime) {
                return "\(formattedStartDate) \(formattedStartTime)"
            } else {
                return "\(formattedStartDate) (\(formattedStartTime) - \(formattedEndTime))"
            }
        } else {
            return "\(formattedStartDate) \(formattedStartTime) - \(formattedEndDate) \(formattedEndTime)"
        }
    }
}

func formatTimeInterval(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    formatter.maximumUnitCount = 2
    return formatter.string(from: interval) ?? ""
}
