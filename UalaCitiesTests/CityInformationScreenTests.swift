//
//  CityInformationScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 03/09/2025.
//

import XCTest
@testable import UalaCities

class CityInformationScreenTests: XCTestCase {
    func test_showsCityContent() throws {
        let city = City.from(TestData.Cities.sidney)
        let screen = CityInformationScreenViewModel(city: city)
        XCTAssertEqual("City Information", screen.titleText)
        
        let row0 = screen.rows[safe: 0]
        XCTAssertEqual("Name", row0?.titleText)
        XCTAssertEqual("Sidney", row0?.valueText)
        XCTAssertEqual(false, row0?.isShowingArrow)
        
        let row1 = screen.rows[safe: 1]
        XCTAssertEqual("Country Code", row1?.titleText)
        XCTAssertEqual("AU", row1?.valueText)
        XCTAssertEqual(false, row1?.isShowingArrow)
        
        let row2 = screen.rows[safe: 2]
        XCTAssertEqual("Coordinates", row2?.titleText)
        XCTAssertEqual("-99.079689, 49.900028", row2?.valueText)
        XCTAssertEqual(true, row2?.isShowingArrow)
        
        XCTAssertNil(screen.rows[safe: 3])
    }
}
