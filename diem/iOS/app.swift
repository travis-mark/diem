//  diem/iOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct PrimaryView: View {
    @State private var date = Date()
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Small Widgets").bold()
                HStack(spacing: 8) {
                    VStack {
                        DateView(date: date)
                            .modifier(WidgetBoxModifier())
                    }
                    VStack {
                        DayView(date: date)
                            .modifier(WidgetBoxModifier())
                    }
                    VStack {
                        YearDayView(date: date)
                            .modifier(WidgetBoxModifier())
                    }
                    
                    VStack {
                        YearWeekView(date: date)
                            .modifier(WidgetBoxModifier())
                    }
                }
            }
            VStack {
                Text("Large Widgets").bold()
                EverythingView(date: date)
                    .modifier(WidgetBoxModifier())
            }
            VStack(spacing: 4) {
                Text("Adding Widgets on Apple Watch").bold()
                Text("Long-press in the center of the watch. Tap the (Edit) button in the bottom right corner and swipe right to edit complications. Select the complications to replace and scroll to find the Diem widget you want to add.")
            }
            VStack {
                Text("Start Lisp Test")
                ExprView(expr: .cell(.symbol("vstack"), .cell(.string("Hello, parens!"), .cell(.cell(.symbol("nsdateformat"), .string("D")), .null))))
            }
        }
        .padding(20)
        .onAppear {
            date = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            date = Date()
        }
    }
}

struct ContentView: View {
    var body: some View {
        PrimaryView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@main struct diemApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .background:
                addActions()
            default:
                break
            }
        }
    }

    private func addActions() {
        let date = Date()
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: string(from: date, format: "MMMM d")),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: string(from: date, format: "F EEE").toOrdinalAll),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: string(from: date, format: "'Day' D")),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: string(from: date, format: "'Week' ww")),
        ]
    }
}
