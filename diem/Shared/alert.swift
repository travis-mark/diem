//  diem/alert.swift
//  Created by Travis Luckenbaugh on 8/26/23.

import Foundation
import UserNotifications

func setupNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            _setupNotifications_afterAuthorizationGranted()
        } else {
            // TODO: Error path
        }
    }
}

private func _setupNotifications_afterAuthorizationGranted() {
    // Create an object with notification details
    let content = UNMutableNotificationContent()
    content.title = "5th Tuesday"
    content.subtitle = "..."
    content.body = "(╯°□°)╯ ┻━┻"
    // Create a trigger for the notification (time interval, date, etc...)
    let t0 = Date()
    let calendar = Calendar.current
    let components = DateComponents(weekday: 3, weekdayOrdinal: 5)
    let t1 = calendar.nextDate(after: t0, matching: components, matchingPolicy: .strict)!
    let dt = t1.timeIntervalSince1970 - t0.timeIntervalSince1970
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: dt, repeats: false)
    // Wrap content and trigger in a request
    let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)
    // Add the request to the notification center
    UNUserNotificationCenter.current().add(request) { (error) in
        // TODO: Error path
    }
}
