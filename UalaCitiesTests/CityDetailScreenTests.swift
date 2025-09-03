//
//  CityDetailScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 03/09/2025.
//

import XCTest
@testable import UalaCities

class CityDetailScreenTests: XCTestCase {
    func test_showsCityContent() throws {
        let city = City.from(TestData.Cities.sidney)
        let screen = CityDetailScreenViewModel(city: city)
        XCTAssertEqual("City Information", screen.titleText)
        
        XCTAssertEqual("Name", screen.rows[safe: 0]?.titleText)
        XCTAssertEqual("Sidney", screen.rows[safe: 0]?.valueText)
        
        XCTAssertEqual("Country Code", screen.rows[safe: 1]?.titleText)
        XCTAssertEqual("AU", screen.rows[safe: 1]?.valueText)
        
        XCTAssertEqual("Coordinates", screen.rows[safe: 2]?.titleText)
        XCTAssertEqual("-99.079689, 49.900028", screen.rows[safe: 2]?.valueText)
        
        XCTAssertNil(screen.rows[safe: 3])
    }
}
