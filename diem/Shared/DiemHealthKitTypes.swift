//  diem/Shared - DiemHealthKitTypes.swift
//  Created by Travis Luckenbaugh on 6/29/24.

import Foundation

struct DiemHealthKitType {
    let key: String
}

enum DiemHealthKitTypes {
    static var dataSource: [DiemHealthKitType] = []
    
    static func needsReload() -> Bool {
        return dataSource.isEmpty
    }
    
    static func reloadData() {
        guard let path = Bundle.main.path(forResource: "health", ofType: "csv") else {
            fatalError("Failed to find health.csv in bundle.")
        }
        let contents: String
        do {
            contents = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            fatalError("Failed to load health.csv: \(error.localizedDescription)")
        }
        // TODO: TL 06/29/24 Skip header, actual CSV parse or change delimiter
        dataSource = contents.components(separatedBy: .newlines).map({ line in
            let fields = line.components(separatedBy: ",")
            return DiemHealthKitType(key: fields[0])
        })
    }
    
    // TODO: TL 06/29/24 ordering
    static func all() -> [DiemHealthKitType] {
        if needsReload() {
            reloadData()
        }
        return dataSource
    }
}
