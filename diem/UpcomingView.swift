//  diem/iOS - UpcomingView.swift
//  Created by Travis Luckenbaugh on 8/31/24.

import SwiftUI
import EventKit

let eventStore = EKEventStore()
extension EKCalendar: Identifiable {}
extension EKEvent: Identifiable {}

struct UpcomingEvent {
    var calendarIdentifier: String
    var eventIdentifier: String
    var title: String
    var startDate: Date?
    var endDate: Date?
    var isAllDay: Bool
    var occurances: Int = 1
}

struct UpcomingView: View {
    @State var calendars = [EKCalendar]()
    @State var upcomingEvents = [UpcomingEvent]()
    @State var error: Error?
    
    var body: some View {
        List(calendars) { calendar in
            Section(header: Text(calendar.title)) {
                let calendarEvents = upcomingEvents.filter { $0.calendarIdentifier == calendar.calendarIdentifier }
                ForEach(calendarEvents, id: \.eventIdentifier) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.occurances == 1 
                             ? formatDateRange(event.startDate, event.endDate)
                             : "\(formatDateRange(event.startDate, event.endDate)) and \(event.occurances) other(s)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    let calendars = eventStore.calendars(for: .event)
                    let startDate = Date()
                    let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
                    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                    let events = eventStore.events(matching: predicate)
                    var upcomingEvents = [UpcomingEvent]()
                    for event in events {
                        if let index = upcomingEvents.firstIndex(where: { $0.title == event.title }) {
                            upcomingEvents[index] = UpcomingEvent(
                                calendarIdentifier: upcomingEvents[index].calendarIdentifier,
                                eventIdentifier: upcomingEvents[index].eventIdentifier,
                                title: upcomingEvents[index].title,
                                startDate: upcomingEvents[index].startDate,
                                endDate: upcomingEvents[index].endDate,
                                isAllDay: upcomingEvents[index].isAllDay,
                                occurances: upcomingEvents[index].occurances + 1)
                        } else {
                            upcomingEvents.append(
                                UpcomingEvent(
                                    calendarIdentifier: event.calendar.calendarIdentifier,
                                    eventIdentifier: event.eventIdentifier,
                                    title: event.title,
                                    startDate: event.startDate,
                                    endDate: event.endDate,
                                    isAllDay: event.isAllDay
                                ))
                        }
                    }
                    self.calendars = calendars
                    self.upcomingEvents = upcomingEvents
                    self.error = nil
                } else if let error {
                    self.error = error
                } else {
                    print("Access to calendar not granted")
                    abort()
                }
            }
        }
    }
}
