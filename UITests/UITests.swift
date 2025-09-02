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
    
    func test_smoke_citiesLoadedAndShown_filter() throws {
        var app = XCUIApplication()
        app.launchEnvironment["UITests"] = "true"
        app.launch()
        
        let loadingView = app.staticTexts["Loading Cities..."]
        XCTAssertTrue(loadingView.waitForExistence(timeout: 10.0))
        
        let firstRowTitle = app.staticTexts["'t Hoeksken, BE"]
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
        
        // favorite filter (empty)
        let favoriteFilterButton = app.buttons["FavoriteFilterButton"]
        XCTAssertTrue(favoriteFilterButton.waitForExistence(timeout: 10.0))
        favoriteFilterButton.tap()
        XCTAssertTrue(favoriteFilterButton.isSelected)
        
        let noResultsTitle = app.staticTexts["No cities found"]
        XCTAssertTrue(noResultsTitle.waitForExistence(timeout: 10.0))
        
        favoriteFilterButton.tap()
        XCTAssertFalse(favoriteFilterButton.isSelected)
        
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
        
        // query filter
        let searchBar = app.searchFields["Filter"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 10.0))
        searchBar.tap()
        searchBar.typeText("Tandil")
        
        let filteredRowTitle = app.staticTexts["Tandil, AR"]
        XCTAssertTrue(filteredRowTitle.waitForExistence(timeout: 10.0))
        
        // Add to favorites
        let filteredRowFavoriteButton = app.buttons["FavoriteButton"]
        XCTAssertTrue(filteredRowFavoriteButton.waitForExistence(timeout: 10.0))
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
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
        
        // filter again with favorites
        favoriteFilterButton.tap()
        XCTAssertTrue(favoriteFilterButton.isSelected)
        XCTAssertTrue(filteredRowTitle.waitForExistence(timeout: 10.0))
        
        // favorites persistence
        app.terminate()
        
        app = XCUIApplication()
        app.launch()

        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
        XCTAssertTrue(favoriteFilterButton.waitForExistence(timeout: 10.0))
        favoriteFilterButton.tap()
        
        XCTAssertTrue(filteredRowTitle.waitForExistence(timeout: 10.0))
        
        // map
        filteredRowTitle.tap()
        
        let mapScreenTitle = app.navigationBars["Tandil, AR"]
        XCTAssertTrue(mapScreenTitle.waitForExistence(timeout: 10.0))
        
        app.navigationBars.buttons["Back"].tap()
        
        // back to list
        XCTAssertTrue(filteredRowTitle.waitForExistence(timeout: 10.0))
    }
    
    func test_error_and_retry() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UITests"] = "true"
        app.launchEnvironment["UITestScenario"] = UITestScenarios.loadCitiesErrorAndRetry.rawValue
        app.launch()
        
        let errorHeading = app.staticTexts["Something went wrong"]
        XCTAssertTrue(errorHeading.waitForExistence(timeout: 20.0))
        
        errorHeading.tap()
        
        let firstRowTitle = app.staticTexts["City, AA"]
        XCTAssertTrue(firstRowTitle.waitForExistence(timeout: 10.0))
    }
}
