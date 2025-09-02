//
//  CitiesScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

class CitiesScreenTests: XCTestCase {
    class Make {
        let httpClient: ControlledHTTPClient
        let runner: AsyncRunner
        let userDefaults: AppleUserDefaults
        
        init(
            httpClient: ControlledHTTPClient = ControlledHTTPClient(),
            runner: AsyncRunner = ImmediateRunner(),
            userDefaults: AppleUserDefaults = InRamAppleUserDefaults()
        ) {
            self.httpClient = httpClient
            self.runner = runner
            self.userDefaults = userDefaults
        }
        func sut() -> CitiesScreenViewModel{
            let citiesAPI = CitiesAPI(httpClient: httpClient)
            let citiesStore = CitiesStore(citiesAPI: citiesAPI, runner: runner, userDefaults: userDefaults)
            return .init(citiesStore: citiesStore)
        }
    }
    
    func testLoadCitiesOk() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
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
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)

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
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.sidney, TestData.Cities.denver])
        ))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Denver, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 1]?.headingText)
    }
    
    func testFilterOnlyWhenCitiesAreLoaded() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        screen.onAppear()
        
        _ = try XCTUnwrap(httpClient.pendingRequests.unique())

        screen.searchBarType("")
        XCTAssertTrue(screen.isShowingSpinner)
        
        screen.onTapFavoriteFilterButton()
        XCTAssertTrue(screen.isShowingSpinner)
    }
    
    func testFilter() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
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
        XCTAssertEqual("Alabama, US", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.citiesListItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.citiesListItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.citiesListItems[safe: 3]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 4]?.headingText)
        
        screen.searchBarType("s")
        XCTAssertEqual("s", screen.searchBarText)
        XCTAssertEqual("Sidney, AU", screen.citiesListItems[safe: 0]?.headingText)
        XCTAssertNil(screen.citiesListItems[safe: 1])
    }
    
    func testFilterNoResults() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.arizona])))))
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Arizona, US", screen.citiesListItems.first?.headingText)
        
        screen.searchBarType("X")
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertTrue(screen.isShowingEmptyView)
        XCTAssertEqual("No cities found", screen.emptyHeadingText)
        XCTAssertEqual("Try adjusting your search", screen.emptySubheadText)
        
        screen.searchBarTypeDelete()
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.isShowingEmptyView)
        XCTAssertEqual("Arizona, US", screen.citiesListItems.first?.headingText)
        
        screen.searchBarType("A")
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.isShowingEmptyView)
        XCTAssertEqual("Arizona, US", screen.citiesListItems.first?.headingText)
        
        screen.searchBarType("X")
        
        XCTAssertTrue(screen.isShowingEmptyView)
        XCTAssertEqual("No cities found", screen.emptyHeadingText)
        XCTAssertEqual("Try adjusting your search", screen.emptySubheadText)
        
        screen.searchBarTypeDelete()
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.isShowingEmptyView)
        XCTAssertEqual("Arizona, US", screen.citiesListItems.first?.headingText)
    }
    
    func test_filterByFavorites() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        XCTAssertEqual("Alabama, US", screen.citiesListItems.first?.headingText)
        
        XCTAssertFalse(screen.favoriteFilterButtonIsSelected)
        
        screen.onTapFavoriteFilterButton()
        XCTAssertTrue(screen.favoriteFilterButtonIsSelected)
        
        XCTAssertNil(screen.citiesListItems.first)
        
        screen.onTapFavoriteFilterButton()
        XCTAssertFalse(screen.favoriteFilterButtonIsSelected)
        
        // add favorite
        let sidneyRow = try XCTUnwrap(screen.citiesListItems.last)
        XCTAssertEqual("Sidney, AU", sidneyRow.headingText)
        XCTAssertFalse(sidneyRow.favoriteButtonIsSelected)
        sidneyRow.onFavoriteButtonTap()
        XCTAssertTrue(sidneyRow.favoriteButtonIsSelected)
        
        // filter favorites
        screen.onTapFavoriteFilterButton()
        XCTAssertTrue(screen.favoriteFilterButtonIsSelected)
        let favoriteRow = try XCTUnwrap(screen.citiesListItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
        XCTAssertTrue(favoriteRow.favoriteButtonIsSelected)
        
        // unfavorite
        favoriteRow.onFavoriteButtonTap()
        XCTAssertNil(screen.citiesListItems.first)
        XCTAssertTrue(screen.isShowingEmptyView)
    }
    
    func test_favoritesPersistence() throws {
        let make1 = Make()
        var (screen, httpClient) = (make1.sut(), make1.httpClient)
        
        screen.onAppear()
        
        var request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        
        // add favorite
        let sidneyRow = try XCTUnwrap(screen.citiesListItems.last)
        XCTAssertEqual("Sidney, AU", sidneyRow.headingText)
        XCTAssertFalse(sidneyRow.favoriteButtonIsSelected)
        sidneyRow.onFavoriteButtonTap()
        XCTAssertTrue(sidneyRow.favoriteButtonIsSelected)
        
        // filter favorites
        screen.onTapFavoriteFilterButton()
        var favoriteRow = try XCTUnwrap(screen.citiesListItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
        XCTAssertTrue(favoriteRow.favoriteButtonIsSelected)

        // new run
        
        let make2 = Make(userDefaults: make1.userDefaults)
        (screen, httpClient) = (make2.sut(), make2.httpClient)
        
        screen.onAppear()
        
        request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        
        screen.onTapFavoriteFilterButton()
        favoriteRow = try XCTUnwrap(screen.citiesListItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
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
