//  diem/iOS - Workouts.swift
//  Created by Travis Luckenbaugh on 9/7/24.

import HealthKit

enum WorkoutDateRange {
    case sevenDays
    case oneMonth
    case threeMonths
    case sixMonths
    case oneYear
    
    var startDate: Date? {
        switch self {
        case .sevenDays:
            return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .oneMonth:
            return Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case .threeMonths:
            return Calendar.current.date(byAdding: .month, value: -3, to: Date())
        case .sixMonths:
            return Calendar.current.date(byAdding: .month, value: -6, to: Date())
        case .oneYear:
            return Calendar.current.date(byAdding: .year, value: -1, to: Date())
        }
    }
}

// TODO:TL:20240908: Units other than miles
func formatDistance(_ distance: HKQuantity?) -> String {
    guard let miles = distance?.doubleValue(for: .mile()) else { return "--" }
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    guard let milesFormatted = formatter.string(from: NSNumber(value: miles)) else { return "--" }
    return "\(milesFormatted) mi"
}

func fetchWorkouts(startDate: Date? = nil) async -> [HKWorkout] {
    return await withCheckedContinuation { cc in
        let store = HKHealthStore()
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
            var predicates = [NSPredicate]()
            predicates.append(HKQuery.predicateForWorkouts(with: .running))
            if let startDate {
                predicates.append(NSPredicate(format: "%K >= %@", HKPredicateKeyPathStartDate, startDate as CVarArg))
            }
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
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
    @State var selectedDateRange: WorkoutDateRange = .sevenDays 
    
    // TODO:TL:20240907: Date / time functions - merge with Upcoming
    static let dateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM d"
        return f
    }()
    
    func didSetSelectedDateRange() {
        Task {
            workouts = await fetchWorkouts(startDate: self.selectedDateRange.startDate)
        }
    }
    
    var body: some View {
        // TODO:TL:20240907: List workouts
        ZStack {
            if let workouts {
                VStack(alignment: .leading) {
                    if let selectedValue {
                        VStack(alignment: .leading) {
                            Text(formatDateRange(selectedValue.startDate, selectedValue.endDate)).font(.title)
                            HStack {
                                // TODO:TL:20240907: Distance
                                // TODO:TL:20240907: Elev Gain
                                // TODO:TL:20240907: Calories
                                VStack(alignment: .leading) {
                                    Text("Distance")
                                    Text(formatDistance(selectedValue.totalDistance))
                                }
                                VStack(alignment: .leading) {
                                    Text("Time")
                                    Text("\(formatTimeInterval(selectedValue.duration))")
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
                    if #available(iOS 17.0, *) {
                        Picker("", selection: $selectedDateRange) {
                            Text("7D").tag(WorkoutDateRange.sevenDays)
                            Text("1M").tag(WorkoutDateRange.oneMonth)
                            Text("3M").tag(WorkoutDateRange.threeMonths)
                            Text("6M").tag(WorkoutDateRange.sixMonths)
                            Text("1Y").tag(WorkoutDateRange.oneYear)
                        }
                        .onChange(of: selectedDateRange) {
                            didSetSelectedDateRange()
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    } else {
                        // TODO:TL:20240919: Make iOS 17 min or find different approach
                    }
                }
            } else {
                ProgressView()
            }
        }.onAppear(perform: didSetSelectedDateRange)
    }
}
