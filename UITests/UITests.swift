//
//  UITests.swift
//  UITests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

final class UITests: XCTestCase {
    @MainActor
    
    func test_smoke_citiesLoadedAndShown() throws {
        let app = XCUIApplication()
        app.launch()
        
        let firstRowTitle = app.staticTexts["'t Hoeksken, BE"]
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
        
//        app.searchFields["Filter"].typeText("T")
    }
    
    func test_error_and_retry() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITestScenario"] = UITestScenarios.loadCitiesErrorAndRetry.rawValue
        app.launch()
        
        let errorHeading = app.staticTexts["Something went wrong"]
        XCTAssertTrue(errorHeading.waitForExistence(timeout: 20.0))
        
        errorHeading.tap()
        
        let firstRowTitle = app.staticTexts["City, AA"]
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
    }
}
