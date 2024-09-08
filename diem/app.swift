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
                            if !request.content.subtitle.isEmpty {
                                Text(request.content.subtitle).font(.caption)
                            }
                            if let displayString = request.trigger?.displayString {
                                Text(displayString)
                            }
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
            AlertsDetail(action: {
                child = nil
                Task() {
                    requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                }
            })
        }
    }
}

enum NotificationFrequencyUnit {
    case daily
    case weekly
    case monthly
    case yearly
}

struct AlertsDetail: View {
    // TODO: Move state to class
    @State var contentTitle: String = ""
    @State var contentSubtitle: String = ""
    @State var contentBody: String = ""
    @State var notificationFrequencyUnit: NotificationFrequencyUnit = .daily
    @State var notificationFrequencySubunit: NotificationFrequencyUnit = .daily
    @State var notificationFrequencyCount: Int = 1
    @State var notificationFrequencyDateComponents: [DateComponents] = []
    
    let action: (() -> Void)?
    
    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Text("Title")
                        Spacer()
                        TextField("", text: $contentTitle)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Subtitle")
                        Spacer()
                        TextField("", text: $contentSubtitle)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Body")
                        Spacer()
                        TextField("", text: $contentBody)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Picker("", selection: $notificationFrequencyUnit) {
                            Text("Daily").tag(NotificationFrequencyUnit.daily)
                            Text("Weekly").tag(NotificationFrequencyUnit.weekly)
                            Text("Monthly").tag(NotificationFrequencyUnit.monthly)
                            Text("Yearly").tag(NotificationFrequencyUnit.yearly)
                        }
                    }
                    HStack {
                        Text("Every")
                        Spacer()
                        Picker("", selection: $notificationFrequencyCount) {
                            ForEach(1..<1000) { index in
                                Text(String(index)).tag(index)
                            }
                        }
                        switch notificationFrequencyUnit {
                        case .daily: notificationFrequencyCount == 1 ? Text("Day") : Text("Days")
                        case .weekly: notificationFrequencyCount == 1 ? Text("Week") : Text("Weeks")
                        case .monthly: notificationFrequencyCount == 1 ? Text("Month") : Text("Months")
                        case .yearly: notificationFrequencyCount == 1 ? Text("Year") : Text("Years")
                        }
                    }
                }
                if notificationFrequencyUnit == .weekly {
                    Section {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.0) { symbol in
                            HStack {
                                Text(symbol.element)
                                Spacer()
                                if notificationFrequencyDateComponents.contains(DateComponents(weekday: symbol.offset + 1)) {
                                    Image(systemName: "checkmark").foregroundColor(Color("AccentColor"))
                                }
                            }.onTapGesture {
                                if let index = notificationFrequencyDateComponents.firstIndex(of: DateComponents(weekday: symbol.offset)) {
                                    notificationFrequencyDateComponents.remove(at: index)
                                } else {
                                    notificationFrequencyDateComponents.append(DateComponents(weekday: symbol.offset + 1))
                                }
                            }
                        }
                    }
                }
                // TODO: Monthly view
                // TODO: Yearly View
            }
            Button("Save") {
                let content = UNMutableNotificationContent()
                content.title = contentTitle
                content.subtitle = contentSubtitle
                content.body = contentBody
                Task() {
                    do {
                        try await setupNotifications(content: content, componentsArray: notificationFrequencyDateComponents)
                        action?()
                    } catch (let error) {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            .font(.headline)
            .foregroundColor(Color.white)
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
            .padding(10)
        }
        
    }
}

struct HealthDataPointView: View {
    let data: HealthDataPoint
    var body: some View {
        HStack {
            Text(LocalizedStringKey(data.type.identifier))
            Spacer()
            Text(data.value.displayString)
        }
    }
}

// TODO: 2024-05-15 TL Do I want optional compare view?
struct HealthView: View {
    @ObservedObject var state = HealthState()
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            switch (state.state) {
            case .unknown:
                Text("TODO Unknown")
            case .loading:
                ProgressView()
            case .ready(let points):
                List(points, id: \.type) { point in
                    HealthDataPointView(data: point)
                }
            }
            Spacer()
            HStack {
                Button() {
                    self.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: self.selectedDate)!
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                }.padding(22)
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                ).onChange(of: selectedDate) { newDate in
                    state.dateRange = dayRange(for: selectedDate)
                }
                .frame(width: 160)
                .labelsHidden()
                Button() {
                    self.selectedDate = Calendar.current.date(byAdding: .day, value: +1, to: self.selectedDate)!
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 24, weight: .bold))
                }.padding(22)
            }
        }.onAppear {
            Task() {
                state.refresh()
            }
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
            UpcomingView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Up Next")
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
            AlertsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Alerts")
                }
            TextFileView(url: Bundle.main.url(forResource: "health", withExtension: "csv")!)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("File")
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
