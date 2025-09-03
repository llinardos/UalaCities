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
    func test_smoke() throws {
        XCUIDevice.shared.orientation = .portrait
        
        var app = XCUIApplication()
        app.launchEnvironment["UITests"] = "true"
        app.launch()
        
        let loadingView = app.staticTexts["Loading Cities..."]
        assertExistence(of: loadingView)
        
        let firstRowTitle = app.staticTexts["'t Hoeksken, BE"]
        assertExistence(of: firstRowTitle)
        
        // favorite filter (empty)
        let favoriteFilterButton = app.buttons["FavoriteFilterButton"]
        assertExistence(of: favoriteFilterButton)
        favoriteFilterButton.tap()
        XCTAssertTrue(favoriteFilterButton.isSelected)
        
        let noResultsTitle = app.staticTexts["No cities found"]
        assertExistence(of: noResultsTitle)
        
        favoriteFilterButton.tap()
        XCTAssertFalse(favoriteFilterButton.isSelected)
        
        assertExistence(of: firstRowTitle)
        
        // query filter
        let searchBar = app.searchFields["Filter"]
        assertExistence(of: searchBar)
        searchBar.tap()
        searchBar.typeText("Tandil")
        
        let filteredRowTitle = app.staticTexts["Tandil, AR"]
        assertExistence(of: filteredRowTitle)
        
        // Add to favorites
        let filteredRowFavoriteButton = app.buttons["FavoriteButton"]
        assertExistence(of: filteredRowFavoriteButton)
        XCTAssertFalse(filteredRowFavoriteButton.isSelected)
        filteredRowFavoriteButton.tap()
        XCTAssertTrue(filteredRowFavoriteButton.isSelected)
        
        // clean query filter
        searchBar.typeText("\u{8}")
        searchBar.typeText("\u{8}")
        searchBar.typeText("\u{8}")
        searchBar.typeText("\u{8}")
        searchBar.typeText("\u{8}")
        searchBar.typeText("\u{8}")
        assertExistence(of: firstRowTitle)
        
        // filter again with favorites
        favoriteFilterButton.tap()
        XCTAssertTrue(favoriteFilterButton.isSelected)
        assertExistence(of: filteredRowTitle)
        
        // go to info
        let filteredRowInfoButton = app.buttons["InfoButton"]
        assertExistence(of: filteredRowInfoButton)
        filteredRowInfoButton.tap()
        
        let infoScreenTitle = app.navigationBars["City Information"]
        assertExistence(of: infoScreenTitle)
        assertExistence(of: app.staticTexts.firstMatch)
        
        let coordinatesRowInInfoScreen = app.staticTexts["Coordinates"]
        assertExistence(of: coordinatesRowInInfoScreen)
        coordinatesRowInInfoScreen.tap()
        
        let mapScreenTitleFromInfoScreen = app.navigationBars["Tandil, AR"]
        assertExistence(of: mapScreenTitleFromInfoScreen)
        assertExistence(of: app.maps.firstMatch)
        
        // favorites persistence
        app.terminate()
        
        app = XCUIApplication()
        app.launch()

        assertExistence(of: firstRowTitle)
        assertExistence(of: favoriteFilterButton)
        favoriteFilterButton.tap()
        
        assertExistence(of: filteredRowTitle)
        
        // map
        filteredRowTitle.tap()
        
        let mapScreenTitle = app.navigationBars["Tandil, AR"]
        assertExistence(of: mapScreenTitle)
        assertExistence(of: app.maps.firstMatch)
        
        app.navigationBars.buttons["Back"].tap()
        
        // back to list
        assertExistence(of: filteredRowTitle)
        
        // orientation
        XCUIDevice.shared.orientation = .landscapeRight
        let emptyMapTitle = app.staticTexts["No City Selected"]
        assertExistence(of: emptyMapTitle)
        
        XCUIDevice.shared.orientation = .portrait
    }
    
    func test_error_and_retry() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITests"] = "true"
        app.launchEnvironment["UITestScenario"] = UITestScenarios.loadCitiesErrorAndRetry.rawValue
        app.launch()
        
        let errorHeading = app.staticTexts["Something went wrong"]
        assertExistence(of: errorHeading)
        
        errorHeading.tap()
        
        let firstRowTitle = app.staticTexts["City, AA"]
        assertExistence(of: firstRowTitle)
    }
}

extension XCTestCase {
    @discardableResult
    func assertExistence(of element: XCUIElement, timeout: TimeInterval = 10.0, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)
        return element
    }
}
