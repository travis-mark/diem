//  diem/iOS - HealthView.swift
//  Created by Travis Luckenbaugh on 1/10/25.

import SwiftUI

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
            DatePickerView(date: $selectedDate)
                .onChange(of: selectedDate, initial: true, {_, newDate in
                    state.dateRange = dayRange(for: selectedDate)
            })
        }.onAppear {
            Task() {
                state.refresh()
            }
        }
    }
}
