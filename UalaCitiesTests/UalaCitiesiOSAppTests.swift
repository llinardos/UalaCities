//
//  UalaCitiesTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

final class UalaCitiesiOSAppTests: XCTestCase {
    func test_beginsWithCitiesScreen() {
        let app = iOSAppViewModel()
        XCTAssertTrue(app.mainScreen is CitiesScreenViewModel, "got \(type(of: app.mainScreen))")
    }
}
