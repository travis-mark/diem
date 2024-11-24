//  diem/watchOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    @State private var offset: Double = 0
    var body: some View {
        VStack(spacing: 20) {
            EverythingView(date: date)
                .focusable(true)
//            TODO: 2024-11-24 - Write custom modifier to support infinite scroll
                .digitalCrownRotation($offset, from: -2, through: 2, by: 1, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: false)
                .onChange(of: offset) { newValue in
                    guard let offsetDate = Calendar.current.date(byAdding: .day, value: Int(newValue), to: Date())  else {
                        return
                    }
                    date = offsetDate
                }
            if offset != 0 {
                Button(action: {
                    date = Date()
                    offset = 0
                }) {
                    Text("Reset")
                }
            }
        }
    }
}

@main struct DiemWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
