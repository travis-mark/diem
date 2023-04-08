//  diem/watchOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct ContentView: View {
    let date = Date()
    var body: some View {
        VStack {
            HStack {
                DateView(date: date).modifier(WidgetBoxModifier())
                DayView(date: date).modifier(WidgetBoxModifier())
            }
            HStack {
                YearDayView(date: date).modifier(WidgetBoxModifier())
                YearWeekView(date: date).modifier(WidgetBoxModifier())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@main struct diem_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
