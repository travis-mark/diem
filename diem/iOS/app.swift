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
                Text("Inline Widgets").bold()
                DateInlineView(date: date)
                    .modifier(WidgetBoxModifier())
                YearInlineView(date: date)
                    .modifier(WidgetBoxModifier())
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

struct AlertsView: View {
    @State var weekday: Int = 0
    @State var weekdayOrdinal: Int = 0
    var dateComponents: DateComponents {
        DateComponents(weekday: weekday + 1, weekdayOrdinal: weekdayOrdinal + 1)
    }
    var body: some View {
        VStack {
            Spacer(minLength: 20)
            Button(action: {
                setupNotifications(components: dateComponents)
            }) {
                Text("Create Notification on \(nextDate(after:Date(), matching:dateComponents))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer(minLength: 20)
            HStack {
                Picker(selection: $weekday, label: Text("Day")) {
                    ForEach(0..<7) { index in
                        Text(Calendar.current.weekdaySymbols[index])
                    }
                }
                Spacer()
                Picker(selection: $weekdayOrdinal, label: Text("Ordinal")) {
                    ForEach(1..<6) { index in
                        Text(ordinalFormatter.string(from: NSNumber(value: index))!)
                    }
                }
            }
            Spacer(minLength: 20)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            PrimaryView()
                .tabItem {
                    Image(systemName: "applewatch")
                    Text("Watch")
                }
            AlertsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Alerts")
                }
        }
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
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("MMM/s d/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("F/o EEE/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("Day D/s", date)),
            UIApplicationShortcutItem(type: "com.tl.diem.shortcut.info", localizedTitle: evalDateFormat("Week ww/s", date)),
        ]
    }
}
