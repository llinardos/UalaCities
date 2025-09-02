//
//  CitiesScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

class TestData {
    class Cities {
        static var city1 = City(name: "City 1", country: "AA")
        static var city2 = City(name: "City 2", country: "BB")
        static var hurzuf = City(name: "Hurzuf", country: "UA")
        static var denver = City(name: "Denver", country: "US")
        static var sidney = City(name: "Sidney", country: "AU")
        static var alabama = City(name: "Alabama", country: "US")
        static var albuquerque = City(name: "Albuquerque", country: "US")
        static var anaheim = City(name: "Anaheim", country: "US")
        static var arizona = City(name: "Arizona", country: "US")
        static var filterExample = [alabama, albuquerque, anaheim, arizona, sidney]
    }
}

class CitiesScreenTests: XCTestCase {
    func testLoadCitiesOk() throws {
        let httpClient = ControlledHTTPClient()
        let screen = CitiesScreenViewModel(httpClient: httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        XCTAssertTrue(screen.isShowingSpinner)
        XCTAssertEqual("Loading Cities...", screen.spinnerText)
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.hurzuf])))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Hurzuf, UA", screen.citiesListItems.first?.headingText)
    }
    
    func testLoadCitiesFailsAndRetry() throws {
        let httpClient = ControlledHTTPClient()
        let screen = CitiesScreenViewModel(httpClient: httpClient)

        screen.onAppear()
        
        XCTAssertFalse(screen.isShowingError)
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 500))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingError)
        XCTAssertEqual("Something went wrong", screen.errorHeading)
        XCTAssertEqual("Tap to try again", screen.errorSubhead)
        
        // tap on error to retry
        screen.onErrorTap()
        
        XCTAssertFalse(screen.isShowingError)
        XCTAssertTrue(screen.isShowingSpinner)
        
        let newRequest = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, newRequest.urlString)
        XCTAssertTrue(try httpClient.respond(to: newRequest, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.city1])))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("City 1, AA", screen.citiesListItems.first?.headingText)
    }
    
    func testSorted() throws {
        let httpClient = ControlledHTTPClient()
        let screen = CitiesScreenViewModel(httpClient: httpClient)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.sidney, TestData.Cities.denver])
        ))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Denver, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 1]?.headingText)
    }
    
    func testFilter() throws {
        let httpClient = ControlledHTTPClient()
        let screen = CitiesScreenViewModel(httpClient: httpClient)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)
        ))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Alabama, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.citiesListItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.citiesListItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.citiesListItems[safe: 3]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 4]?.headingText)
        
        XCTAssertEqual("Filter", screen.searchBarPlaceholder)
        screen.searchBarType("A")
        XCTAssertEqual("A", screen.searchBarText)
        
        XCTAssertEqual("Alabama, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.citiesListItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.citiesListItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.citiesListItems[safe: 3]?.headingText)
        XCTAssertNil(screen.citiesListItems[safe: 4])
        
        screen.searchBarType("l")
        XCTAssertEqual("Al", screen.searchBarText)
        
        XCTAssertEqual("Alabama, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.citiesListItems[safe: 1]?.headingText)
        XCTAssertNil(screen.citiesListItems[safe: 2])
        
        screen.searchBarType("b")
        XCTAssertEqual("Alb", screen.searchBarText)
        
        XCTAssertEqual("Albuquerque, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertNil(screen.citiesListItems[safe: 1])
        
        screen.searchBarTypeDelete()
        XCTAssertEqual("Al", screen.searchBarText)
        screen.searchBarTypeDelete()
        XCTAssertEqual("A", screen.searchBarText)
        screen.searchBarTypeDelete()
        XCTAssertEqual("", screen.searchBarText)
        
        screen.searchBarType("s")
        XCTAssertEqual("s", screen.searchBarText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertNil(screen.citiesListItems[safe: 1])
    }
    
    func testPaginatedList() {
        let list = PaginatedListViewModel(items: Array(1...25), pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        list.onDidDisplayItemAtIndex(4)
        list.onDidDisplayItemAtIndex(5)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        list.onDidDisplayItemAtIndex(12)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        list.onDidDisplayItemAtIndex(18)
        XCTAssertEqual(Array(1...25), list.visibleItems)
        
        // change items
        list.items = Array(1...12)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...12), list.visibleItems)
    }
    
    func testPaginatedListEmpty() {
        let list = PaginatedListViewModel(items: [Int](), pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual([], list.visibleItems)
    }
    
    func testPaginatedPageSizeBiggerThanItemsCount() {
        let list = PaginatedListViewModel(items: [1,2,3], pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual([1,2,3], list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        XCTAssertEqual([1,2,3], list.visibleItems)
    }
}
