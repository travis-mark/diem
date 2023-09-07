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

func setupNotifications(content: UNNotificationContent, components: DateComponents, previouslyGranted: Bool = false) async throws {
    if !previouslyGranted {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return }
    }
    let id = UUID().uuidString
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    try await UNUserNotificationCenter.current().add(request)
}

func setupNotifications(content: UNNotificationContent, componentsArray: [DateComponents]) async throws {
    let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    guard granted else { return }
    for components in componentsArray {
        try await setupNotifications(content: content, components: components, previouslyGranted: true)
    }
}
