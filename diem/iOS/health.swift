//  diem/iOS - health.swift
//  Created by Travis Luckenbaugh on 5/16/24.

import Foundation
import HealthKit

enum HealthDataValue {
    case loading
    case na
    case value(Double, HKUnit)
    
    var displayString: String {
        switch (self) {
        case .value(let value, let unit):
            // TODO: TL 2024-06-01 Find a better way to do this
            if HKUnit.pound() === unit {
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                return "\(formatter.string(from: NSNumber(value: value)) ?? "--") lbs"
            } else if HKUnit.percent() === unit {
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                return "\(formatter.string(from: NSNumber(value: value * 100)) ?? "--") %"
            } else {
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                return "\(formatter.string(from: NSNumber(value: value)) ?? "--") EACH"
            }
        default:
            return "--"
        }
    }
}



struct HealthDataPoint {
    let value: HealthDataValue
    let type: HKQuantityType
}

func dayRange(for date: Date) -> (Date, Date) {
    let calendar = Calendar.current
    let begin = calendar.startOfDay(for: date)
    let end = calendar.date(byAdding: .day, value: 1, to: begin)!.addingTimeInterval(-1)
    return (begin, end)
}

private let bodyFatPercentageType = HKQuantityType(.bodyFatPercentage)
private let bodyMassType = HKQuantityType(.bodyMass)

class HealthState: ObservableObject {
    var healthStore: HKHealthStore? = nil
    var dateRange: (Date, Date) = (Date(), Date()) {
        didSet {
            refresh()
        }
    }
    @Published var bodyFatPercentage: HealthDataPoint {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var bodyMass: HealthDataPoint {
        didSet {
            objectWillChange.send()
        }
    }
    
    init() {
        self.healthStore = nil
        self.dateRange = dayRange(for: Date())
        self.bodyFatPercentage = HealthDataPoint(value: .loading, type: bodyFatPercentageType)
        self.bodyMass = HealthDataPoint(value: .loading, type: bodyMassType)
    }
    
    public func refresh() {
        Task {
            do {
                DispatchQueue.main.async {
                    self.bodyMass = HealthDataPoint(value: .loading, type: bodyMassType)
                }
                if HKHealthStore.isHealthDataAvailable() {
                    healthStore = HKHealthStore()
                    guard let healthStore = healthStore else { return }
                    let allTypes: Set = [
                        bodyFatPercentageType,
                        bodyMassType,
                    ]
                    let dateRangePredicate = HKQuery.predicateForSamples(withStart: dateRange.0, end: dateRange.1)
                    // TODO: 2024-05-15 TL This call fails silently when not asking for write permissions. Why?
                    try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
                    
                    
                    // Body fat %
                    if healthStore.authorizationStatus(for: bodyFatPercentageType) == .sharingAuthorized {
                        let units = try! await healthStore.preferredUnits(for: Set([bodyFatPercentageType]))[bodyFatPercentageType]!
                        let descriptor = HKSampleQueryDescriptor(
                            predicates: [.quantitySample(type: bodyFatPercentageType, predicate: dateRangePredicate)],
                            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
                            limit: 1
                        )
                        let results = try await descriptor.result(for: healthStore)
                        if results.count > 0 {
                            let values = results.map { $0.quantity.doubleValue(for: units) }
                            let mean = values.reduce(0.0, { $0 + $1 }) / Double(values.count)
                            DispatchQueue.main.async { [unowned self] in
                                bodyFatPercentage = HealthDataPoint(value: .value(mean, units), type: bodyFatPercentageType)
                            }
                        } else {
                            DispatchQueue.main.async { [unowned self] in
                                bodyFatPercentage = HealthDataPoint(value: .na, type: bodyFatPercentageType)
                            }
                        }
                    }
                    
                    // Body mass
                    if healthStore.authorizationStatus(for: bodyMassType) == .sharingAuthorized {
                        let units = try! await healthStore.preferredUnits(for: Set([bodyMassType]))[bodyMassType]!
                        let descriptor = HKSampleQueryDescriptor(
                            predicates: [.quantitySample(type: bodyMassType, predicate: dateRangePredicate)],
                            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
                            limit: 1
                        )
                        let results = try await descriptor.result(for: healthStore)
                        if results.count > 0 {
                            let values = results.map { $0.quantity.doubleValue(for: units) }
                            let mean = values.reduce(0.0, { $0 + $1 }) / Double(values.count)
                            DispatchQueue.main.async { [unowned self] in
                                bodyMass = HealthDataPoint(value: .value(mean, units), type: bodyMassType)
                            }
                        } else {
                            DispatchQueue.main.async { [unowned self] in
                                bodyMass = HealthDataPoint(value: .na, type: bodyMassType)
                            }
                        }
                    }
                    
                    // TODO: TL 2024-05-31 Add more measurements
                    
                } else {
                    // TODO: 2024-05-15 TL Do I need an else here?
                }
            } catch {
                // Typically, authorization requests only fail if you haven't set the
                // usage and share descriptions in your app's Info.plist, or if
                // Health data isn't available on the current device.
                fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
            }
        }
    }
}
