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
        XCTAssertEqual("City Map", screen.titleText)
        XCTAssertEqual("Sidney, AU", screen.cityMapViewModel.pinTitleText)
        XCTAssertEqualCoordinates(city.coordinates, try XCTUnwrap(screen.cityMapViewModel.cameraPosition.region?.center))
        XCTAssertEqualCoordinates(city.coordinates, screen.cityMapViewModel.pinCoordinates)
    }
}
