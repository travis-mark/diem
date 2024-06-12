//  diem/iOS - health.swift
//  Created by Travis Luckenbaugh on 5/16/24.

import Foundation
import HealthKit

/// Format a value with its unit for display (ex: 160.3 lbs)
///
/// Matching against HKUnit requires requesting or retaining a reference to the HKUnit object via HKUnit.pound() and relying on the current behavior of it always being the same object.
///
/// Once matched, Apple's own MassFormatter uses "lb" not "lbs" for non-singular amounts
///
/// So I wrote my own incomplete implementation against NumberFormatter. Seriously, what does Apple even want here?
func format(value: Double, unit: HKUnit) -> String {
    switch (unit.unitString) {
    case "count":
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "--"
    case "count/min":
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: value)) ?? "--") / min"
    case "Cal": // Kcal reports as Cal
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: value * 1000)) ?? "--") Cal"
    case "lb":
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: value)) ?? "--") lbs"
    case "%":
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: value * 100)) ?? "--") %"
    default:
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: value)) ?? "--") \(unit.unitString)"
    }
}

enum HealthDataValue {
    case loading
    case na
    case value(Double, HKUnit)
    
    var displayString: String {
        switch (self) {
        case .value(let value, let unit):
            return format(value: value, unit: unit)
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

class HealthState: ObservableObject {
    var healthStore: HKHealthStore? = nil
    var dateRange: (Date, Date) = (Date(), Date()) {
        didSet {
            refresh()
        }
    }
    @Published var points: [HealthDataPoint] {
        didSet {
            objectWillChange.send()
        }
    }
    
    init() {
        self.healthStore = nil
        self.dateRange = dayRange(for: Date())
        self.points = []
    }
    
    private func fetch(quantityType: HKQuantityType, predicate: NSPredicate) async -> HealthDataPoint {
        let na = HealthDataPoint(value: .na, type: quantityType)
        guard let healthStore = healthStore else { return na }
        guard healthStore.authorizationStatus(for: quantityType) == .sharingAuthorized else { return na }
        guard let units = try? await healthStore.preferredUnits(for: Set([quantityType]))[quantityType] else { return na }
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: quantityType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        guard let results = try? await descriptor.result(for: healthStore) else { return na }
        guard results.count > 0 else { return na }
        let values = results.map { $0.quantity.doubleValue(for: units) }
        let mean = values.reduce(0.0, { $0 + $1 }) / Double(values.count)
        return HealthDataPoint(value: .value(mean, units), type: quantityType)
    }
    
    public func refresh() {
        
        // TODO: 2024-06-11 Finish health strings
        let allTypes = [
            HKQuantityType(.bodyFatPercentage),
            HKQuantityType(.bodyMass),
            HKQuantityType(.activeEnergyBurned),
            // TODO: 2024-06-09 - "Authorization to share the following types is disallowed: HKQuantityTypeIdentifierAppleExerciseTime, HKQuantityTypeIdentifierAppleWalkingSteadiness, HKQuantityTypeIdentifierAppleMoveTime, HKQuantityTypeIdentifierAppleSleepingWristTemperature, HKQuantityTypeIdentifierAtrialFibrillationBurden, HKQuantityTypeIdentifierAppleStandTime" - fuck you too, Apple
//            HKQuantityType(.appleExerciseTime),
//            HKQuantityType(.appleMoveTime),
//            HKQuantityType(.appleSleepingWristTemperature),
//            HKQuantityType(.appleStandTime),
//            HKQuantityType(.appleWalkingSteadiness),
            // TODO: 2024-06-09 - "Authorization to share the following types is disallowed: HKQuantityTypeIdentifierAtrialFibrillationBurden"
//            HKQuantityType(.atrialFibrillationBurden),
            HKQuantityType(.basalBodyTemperature),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.bloodAlcoholContent),
            HKQuantityType(.bloodGlucose),
            HKQuantityType(.bloodPressureDiastolic),
            HKQuantityType(.bloodPressureSystolic),
            HKQuantityType(.bodyMassIndex),
            HKQuantityType(.bodyTemperature),
            // TODO: 2024-06-09 iOS 17 only fields
//            HKQuantityType(.cyclingCadence),
//            HKQuantityType(.cyclingFunctionalThresholdPower),
//            HKQuantityType(.cyclingPower),
//            HKQuantityType(.cyclingSpeed),
            HKQuantityType(.dietaryBiotin),
            HKQuantityType(.dietaryCaffeine),
            HKQuantityType(.dietaryCalcium),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryChloride),
            HKQuantityType(.dietaryCholesterol),
            HKQuantityType(.dietaryChromium),
            HKQuantityType(.dietaryCopper),
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryFatMonounsaturated),
            HKQuantityType(.dietaryFatPolyunsaturated),
            HKQuantityType(.dietaryFatSaturated),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryFiber),
            HKQuantityType(.dietaryFolate),
            HKQuantityType(.dietaryIodine),
            HKQuantityType(.dietaryIron),
            HKQuantityType(.dietaryMagnesium),
            HKQuantityType(.dietaryManganese),
            HKQuantityType(.dietaryMolybdenum),
            HKQuantityType(.dietaryNiacin),
            HKQuantityType(.dietaryPantothenicAcid),
            HKQuantityType(.dietaryPhosphorus),
            HKQuantityType(.dietaryPotassium),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryRiboflavin),
            HKQuantityType(.dietarySelenium),
            HKQuantityType(.dietarySodium),
            HKQuantityType(.dietarySugar),
            HKQuantityType(.dietaryThiamin),
            HKQuantityType(.dietaryVitaminA),
            HKQuantityType(.dietaryVitaminB12),
            HKQuantityType(.dietaryVitaminB6),
            HKQuantityType(.dietaryVitaminC),
            HKQuantityType(.dietaryVitaminD),
            HKQuantityType(.dietaryVitaminE),
            HKQuantityType(.dietaryVitaminK),
            HKQuantityType(.dietaryWater),
            HKQuantityType(.dietaryZinc),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceDownhillSnowSports),
            HKQuantityType(.distanceSwimming),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.electrodermalActivity),
            HKQuantityType(.environmentalAudioExposure),
            HKQuantityType(.environmentalSoundReduction),
            HKQuantityType(.flightsClimbed),
            HKQuantityType(.forcedExpiratoryVolume1),
            HKQuantityType(.forcedVitalCapacity),
            HKQuantityType(.headphoneAudioExposure),
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateRecoveryOneMinute),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.height),
            HKQuantityType(.inhalerUsage),
            HKQuantityType(.insulinDelivery),
            HKQuantityType(.leanBodyMass),
            // TODO: 2024-06-09 - Authorization to share the following types is disallowed
//            HKQuantityType(.nikeFuel),
            HKQuantityType(.numberOfAlcoholicBeverages),
            HKQuantityType(.numberOfTimesFallen),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.peakExpiratoryFlowRate),
            HKQuantityType(.peripheralPerfusionIndex),
            // TODO: 2024-06-09 iOS 17 only fields
//            HKQuantityType(.physicalEffort),
            HKQuantityType(.pushCount),
            HKQuantityType(.respiratoryRate),
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.runningGroundContactTime),
            HKQuantityType(.runningPower),
            HKQuantityType(.runningSpeed),
            HKQuantityType(.runningStrideLength),
            HKQuantityType(.runningVerticalOscillation),
            HKQuantityType(.sixMinuteWalkTestDistance),
            HKQuantityType(.stairAscentSpeed),
            HKQuantityType(.stairDescentSpeed),
            HKQuantityType(.stepCount),
            HKQuantityType(.swimmingStrokeCount),
            // TODO: 2024-06-09 iOS 17 only fields
//            HKQuantityType(.timeInDaylight),
            HKQuantityType(.underwaterDepth),
            HKQuantityType(.uvExposure),
            HKQuantityType(.vo2Max),
            HKQuantityType(.waistCircumference),
            // TODO: 2024-06-09 - Authorization to share the following types is disallowed
//            HKQuantityType(.walkingAsymmetryPercentage),
            HKQuantityType(.walkingDoubleSupportPercentage),
            // TODO: 2024-06-09 - Authorization to share the following types is disallowed
//            HKQuantityType(.walkingHeartRateAverage),
            HKQuantityType(.walkingSpeed),
            HKQuantityType(.walkingStepLength),
            HKQuantityType(.waterTemperature),
        ]
        points = allTypes.map({ HealthDataPoint(value: .loading, type: $0) })
        for t in allTypes {
            print(t.identifier)
        }
        guard HKHealthStore.isHealthDataAvailable() else { return }
        healthStore = HKHealthStore()
        guard let store = healthStore else { return }
        Task {
            do {
                
                let allTypeSet: Set<HKQuantityType> = Set(allTypes)
                // TODO: 2024-05-15 This call fails silently when not asking for write permissions. Why?
                try await store.requestAuthorization(toShare: allTypeSet, read: allTypeSet)
                let dateRangePredicate = HKQuery.predicateForSamples(withStart: dateRange.0, end: dateRange.1)
                var collection: [HealthDataPoint] = []
                for quantityType in allTypes {
                    let point = await fetch(quantityType: quantityType, predicate: dateRangePredicate)
                    collection.append(point)
                }
                let newPoints = collection // Copy annotation to satisfy Swift 6
                DispatchQueue.main.async {
                    self.points = newPoints
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
