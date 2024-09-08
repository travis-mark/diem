//  diem/iOS - Workouts.swift
//  Created by Travis Luckenbaugh on 9/7/24.

import HealthKit

func fetchWorkouts() async -> [HKWorkout] {
    return await withCheckedContinuation { cc in
        let store = HKHealthStore()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        store.requestAuthorization(toShare: Set(), read: Set<HKSampleType>([.workoutType()]), completion: {
            ok, error in
            if let error = error {
                // TODO:TL:20240907: Error handling
                print("Error requesting authorization: \(error.localizedDescription)")
            }
            guard ok else {
                cc.resume(returning: [])
                return
            }
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 5, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                if let error = error {
                    // TODO:TL:20240907: Error handling
                    print("Error fetching workouts: \(error.localizedDescription)")
                }
                let workouts = samples as? [HKWorkout] ?? []
                cc.resume(returning: workouts)
            }
            store.execute(query)
        })
    }
}

// TODO:TL:20240907: Grouping
// TODO:TL:20240907: Metric / formatting
extension HKWorkout {
    var totalDistanceMiles: Double {
        return totalDistance?.doubleValue(for: .mile()) ?? 0.0
    }
}

import SwiftUI
import Charts

struct WorkoutsView: View {
    let color = Color("AccentColor")
    @State var workouts: [HKWorkout]?
    @State var selectedValue: HKWorkout?
    
    // TODO:TL:20240907: Date / time functions - merge with Upcoming
    static let dateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM d"
        return f
    }()
    
    var body: some View {
        // TODO:TL:20240907: List workouts
        // TODO:TL:20240907: 7D | 1M | 3M | 6M | 1Y
        ZStack {
            if let workouts {
                VStack(alignment: .leading) {
                    if let selectedValue {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(WorkoutsView.dateFormatter.string(from: selectedValue.startDate))
                                Text(" - ")
                                Text(WorkoutsView.dateFormatter.string(from: selectedValue.endDate))
                            }.font(.title)
                            HStack {
                                // TODO:TL:20240907: Distance
                                // TODO:TL:20240907: Time formating
                                // TODO:TL:20240907: Elev Gain
                                // TODO:TL:20240907: Calories
                                VStack(alignment: .leading) {
                                    Text("Duration")
                                    Text("\(selectedValue.duration)")
                                }
                            }
                        }.padding()
                    } else {
                        Text("Monthly Sales")
                            .font(.title)
                            .padding()
                    }
                    
                    Chart(workouts, id: \.uuid) { item in
                        // TODO:TL:20240907: Adjust opacity
                        AreaMark(
                            x: .value("Date", item.startDate),
                            y: .value("Distance", item.totalDistanceMiles)
                        )
                        .foregroundStyle(color.opacity(0.3))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Date", item.startDate),
                            y: .value("Distance", item.totalDistanceMiles)
                        )
                        .foregroundStyle(color)
                        .interpolationMethod(.catmullRom)
                        
                        if selectedValue == item {
                            RuleMark(
                                x: .value("Date", item.startDate)
                            )
                            .foregroundStyle(color)
                        }
                        // TODO:TL:20240907: Inner circle
                        // TODO:TL:20240907: Highlight ring
                        PointMark(
                            x: .value("Date", item.startDate),
                            y: .value("Distance", item.totalDistanceMiles)
                        )
                        .foregroundStyle(color)
                        .symbolSize(100) // Adjust this value to change the circle size
                    }
                    .frame(height: 300)
                    .padding()
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0)) // Hide line
                            AxisTick(centered: true, stroke: StrokeStyle(lineWidth: 0))
                            AxisValueLabel()
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let currentX = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                            guard let startDate: Date = proxy.value(atX: currentX) else { return }
                                            selectedValue = workouts.first { startDate > $0.startDate }
                                        }
                                )
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }.onAppear {
            Task {
                workouts = await fetchWorkouts()
            }
        }
    }
}
