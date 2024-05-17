//  diem/iOS - health.swift
//  Created by Travis Luckenbaugh on 5/16/24.

import Foundation
import HealthKit

class HealthState: ObservableObject {
    var healthStore: HKHealthStore? = nil
    var dateRange: (Date, Date) = (Date(), Date())
    
    // TODO: 2024-05-15 TL Expand data structure
    @Published var data: Double = 0.0 {
        didSet {
            objectWillChange.send()
        }
    }
    
    // TODO: 2024-05-15 TL Rename & tie to changing params
    public func startup() async {
        do {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                guard let healthStore = healthStore else { return }
                
                let allTypes: Set = [
                    // Sample types from Apple's documentation
                    //                    HKQuantityType.workoutType(),
                    //                    HKQuantityType(.activeEnergyBurned),
                    //                    HKQuantityType(.distanceCycling),
                    //                    HKQuantityType(.distanceWalkingRunning),
                    //                    HKQuantityType(.distanceWheelchair),
                    //                    HKQuantityType(.heartRate)
                    HKQuantityType(.bodyMass)
                ]
                
                // TODO: 2024-05-15 TL This call fails silently when not asking for write permissions. Why?
                try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
                
                // TODO: 2024-05-15 TL Start loop for multiple values
                let auth = healthStore.authorizationStatus(for: HKQuantityType(.bodyMass))
                if auth == .sharingAuthorized {
                    let dateRangePredicate = HKQuery.predicateForSamples(withStart: dateRange.0, end: dateRange.1)
                    let descriptor = HKSampleQueryDescriptor(
                        predicates: [.quantitySample(type: HKQuantityType(.bodyMass), predicate: dateRangePredicate)],
                        sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
                        limit: 1
                    )
                    let results = try await descriptor.result(for: healthStore)
                    for result in results {
                        DispatchQueue.main.async { [unowned self] in
                            data = result.quantity.doubleValue(for: .pound())
                        }
                    }
                }
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
