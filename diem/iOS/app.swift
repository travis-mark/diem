//  diem/iOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct PrimaryView: View {
    let date = Date()
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Small Widgets")
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
                Text("Large Widgets")
                EverythingView(date: date)
                    .modifier(WidgetBoxModifier())
            }
        }.padding(20)
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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}
