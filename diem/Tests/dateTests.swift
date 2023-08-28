//  diem/dataTests.swift
//  Created by Travis Luckenbaugh on 8/27/23.

import XCTest
@testable import diem

final class DiemDateTests: XCTestCase {
    var isoDateFormatter: DateFormatter!
    
    override func setUpWithError() throws {
        isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFormatter() throws {
        let s_20230827 = "2023-08-27T12:00:00Z"
        let d_20230827 = isoDateFormatter.date(from: s_20230827)!
        assert(evalDateFormat("MMM/s", d_20230827) == "Aug")
        assert(evalDateFormat("d/s", d_20230827) == "27")
        assert(evalDateFormat("F/o", d_20230827) == "4th")
        assert(evalDateFormat("EEE/s", d_20230827) == "Sun")
        assert(evalDateFormat("D/s", d_20230827) == "239")
        assert(evalDateFormat("ww/s", d_20230827) == "35")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
