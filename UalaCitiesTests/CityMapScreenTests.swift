//
//  CityMapScreenViewTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 02/09/2025.
//

import XCTest
@testable import UalaCities

class CityMapScreenViewTests: XCTestCase {
    func test_showsPinAndContent() throws {
        let city = City.from(TestData.Cities.sidney)
        let screen = CityMapScreenViewModel(city: city)
        XCTAssertEqual("Sidney, AU", screen.titleText)
        XCTAssertEqual("Sidney", screen.cityMapViewModel.pinTitleText)
        XCTAssertEqualCoordinates(city.coordinates, try XCTUnwrap(screen.cityMapViewModel.cameraPosition.region?.center))
        XCTAssertEqualCoordinates(city.coordinates, screen.cityMapViewModel.pinCoordinates)
    }
}


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
