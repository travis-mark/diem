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
    @State var requests: [UNNotificationRequest] = []
    @State var child: UNNotificationRequest?
    var hasChild: Binding<Bool> {
        Binding(get: { self.child != nil }, set: {_ in })
    }
    var body: some View {
        VStack {
            List {
                ForEach(requests, id: \.self) { request in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(request.content.title).font(.body)
                            Text(request.content.subtitle).font(.caption)
                        }
                    }.swipeActions {
                        Button(role: .destructive) {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                        } label: {
                          Label("Delete", systemImage: "trash")
                        }
                    }.onTapGesture {
                        child = request
                    }
                }
            }.task {
                requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            }
            Button() {
                let id = UUID().uuidString
                let t0 = Date()
                let t1 = nextDate(after: t0, matching: DateComponents(weekday: 1, weekdayOrdinal: 1))
                let dt = t1.timeIntervalSince1970 - t0.timeIntervalSince1970
                let content = UNMutableNotificationContent()
                content.title = evalDateFormat("F/o EEEE/s", t1)
                content.subtitle = "..."
                content.body = "(╯°□°)╯ ┻━┻"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: dt, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                child = request
            } label: {
                Text("Create Notification")
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            Spacer(minLength: 10)
        }.sheet(isPresented: hasChild) {
            AlertsDetail(alert: child!)
        }
    }
}

struct AlertsDetail: View {
    var alert: UNNotificationRequest
    var body: some View {
        Text("TODO")
    }
}

struct AlertsViewOld: View {
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
