//  diem/iOS - HealthWeightView.swift
//  Created by Travis Luckenbaugh on 9/6/25.

import SwiftUI
import HealthKit

struct HealthWeightView: View {
    @State var isLoading = false
    @State var results: [HKQuantitySample] = []
    @State var unit: HKUnit? = nil
    
    func fetch() async {
        let t0 = Date()
        let healthStore = HealthManager.shared.healthStore
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let quantityType = HKQuantityType(.bodyMass)
        guard healthStore.authorizationStatus(for: quantityType) == .sharingAuthorized else { return }
        let startDate = Date().addingTimeInterval(-8640000000)
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: quantityType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 30
        )
        guard let results = try? await descriptor.result(for: healthStore) else { return }
        let t1 = Date()
        print("-[HealthWeightView fetch] \(t1.timeIntervalSince(t0))")
        self.results = results
        if unit == nil {
            self.unit = try? await healthStore.preferredUnits(for: Set([quantityType]))[quantityType]
        }
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                List(results, id: \.uuid) { result in
                    HStack {
                        Text(result.startDate.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                        Text(result.quantity.formatted(unit: unit))
                    }
                }
            }
        }.onAppear {
            Task {
                isLoading = true
                await fetch()
                isLoading = false
            }
        }.tabItem {
            Image(systemName: "scalemass")
            Text("Weight")
        }
    }
}

/// See format(value: Double, unit: HKUnit)
///
/// TODO: Pick one implementation
extension HKQuantity {
    func formatted(unit: HKUnit? = nil) -> String {
        guard let unit else { return "!!" }
        guard self.is(compatibleWith: unit) else { return "??" }
        let value = self.doubleValue(for: unit)
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        let unitString = unit.unitString == "lb" ? "lbs" : unit.unitString
        guard let valueString = numberFormatter.string(from: NSNumber(value: value)) else { return "--" }
        return "\(valueString) \(unitString)"
    }
}

/// TODO: Move elsewhere if this helps
@MainActor class HealthManager: ObservableObject {
    static let shared = HealthManager()
    let healthStore = HKHealthStore()
}
