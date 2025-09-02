//
//  UITests.swift
//  UITests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest

final class UITests: XCTestCase {
    @MainActor
    
    func test_smoke_citiesLoadedAndShown() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let firstRowTitle = app.staticTexts["Hurzuf"]
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
    }
}
