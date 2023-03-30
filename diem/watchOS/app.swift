//  diem/watchOS - app.swift
//  Created by Travis Luckenbaugh on 3/26/23.

import SwiftUI

struct ContentView: View {
    let date = Date()
    var body: some View {
        VStack {
            Text("\(string(from: date, format: "MMMM dd").toOrdinalAll)")
            Text("\(string(from: date, format: "F EEEE").toOrdinalAll)")
            Text("\(string(from: date, format: "D 'Day'").toOrdinalAll)")
            Text("\(string(from: date, format: "ww 'Week'").toOrdinalAll)")
        }
        .padding()
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
