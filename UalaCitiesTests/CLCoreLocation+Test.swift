//
//  CLCoreLocation+Test.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 03/09/2025.
//

import XCTest
import CoreLocation

func XCTAssertEqualCoordinates(
    _ lhs: CLLocationCoordinate2D,
    _ rhs: CLLocationCoordinate2D,
    accuracy: CLLocationDegrees = 0.000001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(lhs.latitude, rhs.latitude, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(lhs.longitude, rhs.longitude, accuracy: accuracy, file: file, line: line)
}
