//  diem/iOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI



@main struct DiemApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            TabView {
                WidgetPreviewView()
                    .tabItem {
                        Image(systemName: "applewatch")
                        Text("Watch")
                    }
                UpcomingEvents()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Upcoming")
                    }
                HealthView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Health")
                    }
                WorkoutsView()
                    .tabItem {
                        Image(systemName: "figure.run")
                        Text("Workouts")
                    }
            }
        }
        .onChange(of: scenePhase) { _, scenePhase in
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
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("MMM/s d/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("F/o EEE/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("Day D/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("Week ww/s", date)),
        ]
    }
}
