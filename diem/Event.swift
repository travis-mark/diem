import SwiftUI
import EventKit

extension EKAuthorizationStatus {
    var canRead: Bool {
        if #available(iOS 17.0, *) {
            return self == .fullAccess
        } else {
            return self == .authorized
        }
    }
}

class EventStore: ObservableObject {
    @Published var selectedEvents: [EKEvent] = []
    @Published var calendarEvents: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    let eventStore = EKEventStore()
    private let selectedEventsKey = "SelectedEventIdentifiers"
    
    init() {
        checkAuthorization()
        restoreSelectedEvents()
    }
    
    private func restoreSelectedEvents() {
        guard let savedIdentifiers = UserDefaults.standard.array(forKey: selectedEventsKey) as? [String] else {
            return
        }
        
        // Only attempt to restore events if we have calendar access
        if authorizationStatus.canRead {
            savedIdentifiers.forEach { identifier in
                if let event = eventStore.event(withIdentifier: identifier) {
                    selectedEvents.append(event)
                }
            }
            // Clean up any identifiers for events that no longer exist
            saveSelectedEventIdentifiers()
        }
    }
    
    private func saveSelectedEventIdentifiers() {
        let identifiers = selectedEvents.map { $0.eventIdentifier }
        UserDefaults.standard.set(identifiers, forKey: selectedEventsKey)
    }
    
    func checkAuthorization() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        
        if authorizationStatus.canRead {
            fetchEvents()
            restoreSelectedEvents()
        }
    }
    
    func requestAccess()  {
        let completion: EKEventStoreRequestAccessCompletionHandler = {
            [weak self] granted, error in
            DispatchQueue.main.async {
                self?.checkAuthorization()
            }
        }
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completion)
        } else {
            eventStore.requestAccess(to: .event, completion: completion)
        }
    }
    
    func fetchEvents() {
        let calendars = eventStore.calendars(for: .event)
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        calendarEvents = eventStore.events(matching: predicate)
    }
    
    func addEvent(_ event: EKEvent) {
        selectedEvents.append(event)
        saveSelectedEventIdentifiers()
    }
    
    func removeEvent(at index: Int) {
        selectedEvents.remove(at: index)
        saveSelectedEventIdentifiers()
    }
    
    func removeEvent(withIdentifier identifier: String) {
        if let index = selectedEvents.firstIndex(where: { $0.eventIdentifier == identifier }) {
            removeEvent(at: index)
        }
    }
}

struct CalendarAccessView: View {
    @ObservedObject var eventStore: EventStore
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 50))
            Text("Calendar Access Required")
                .font(.title2)
            Text("This app needs access to your calendar to show your events.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Grant Access") {
                eventStore.requestAccess()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct AddEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var eventStore: EventStore
    
    var body: some View {
        NavigationView {
            Group {
                if eventStore.authorizationStatus.canRead {
                    List(eventStore.calendarEvents, id: \.eventIdentifier) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.startDate.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let location = event.location, !location.isEmpty {
                                Text(location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            eventStore.addEvent(event)
                            dismiss()
                        }
                    }
                } else {
                    CalendarAccessView(eventStore: eventStore)
                }
            }
            .navigationTitle("Add from Calendar")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct UpcomingEvents: View {
    @StateObject private var eventStore = EventStore()
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack {
            List {
                ForEach(eventStore.selectedEvents, id: \.eventIdentifier) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.startDate.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if let location = event.location, !location.isEmpty {
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = eventStore.selectedEvents.firstIndex(where: { $0.eventIdentifier == event.eventIdentifier }) {
                                eventStore.selectedEvents.remove(at: index)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showingAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                        .shadow(radius: 4, y: 2)
                }
                .padding()
            }
        }
        .frame(maxHeight: .infinity)
        .sheet(isPresented: $showingAddSheet) {
            AddEventSheet(eventStore: eventStore)
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingEvents()
    }
}
