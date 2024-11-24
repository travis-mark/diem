//  diem/watchOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    @State private var offset: Double = 0
    @State private var previousValue: Double = 0
    @State private var loops: Double = 0
    let minValue: Double = 0
    let maxValue: Double = 4
    var body: some View {
        VStack(spacing: 20) {
            EverythingView(date: date)
                .focusable(true)
                .digitalCrownRotation($offset, from: minValue, through: maxValue, by: 1, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: false)
                .onChange(of: offset) { newValue in
                    let delta = newValue - previousValue
                    if abs(delta) > (maxValue - minValue) * 0.5 {
                        loops += delta < 0 ? 1 : -1
                    }
                    let newOffset = newValue + (maxValue - minValue) * loops
                    guard let offsetDate = Calendar.current.date(byAdding: .day, value: Int(newOffset), to: Date()) else {
                        return
                    }
                    date = offsetDate
                    previousValue = newValue
                }
            if offset != 0 {
                Button(action: {
                    date = Date()
                    offset = 0
                    previousValue = 0
                    loops = 0
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
