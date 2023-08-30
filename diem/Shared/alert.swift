//  diem/alert.swift
//  Created by Travis Luckenbaugh on 8/26/23.

import Foundation
import UserNotifications

let isoDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd"
    return df
}()

let ordinalDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd"
    return df
}()

func nextDate(after date: Date, matching components: DateComponents) -> Date {
    return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .strict)!
}

func setupNotifications(components: DateComponents) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            let t0 = Date()
            let t1 = nextDate(after: t0, matching: components)
            let dt = t1.timeIntervalSince1970 - t0.timeIntervalSince1970
            let id = "date_\(isoDateFormatter.string(from: t1))"
            let content = UNMutableNotificationContent()
            content.title = evalDateFormat("F/o EEEE/s", t1)
            content.subtitle = "..."
            content.body = "(╯°□°)╯ ┻━┻"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: dt, repeats: false)
            // Wrap content and trigger in a request
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            // Add the request to the notification center
            UNUserNotificationCenter.current().add(request) { (error) in
                // TODO: Error path
            }
        } else {
            // TODO: Error path
        }
    }
}
