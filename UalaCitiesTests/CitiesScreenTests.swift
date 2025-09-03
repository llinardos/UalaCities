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
        let deviceOrientation: DeviceOrientation
        
        init(
            httpClient: ControlledHTTPClient = ControlledHTTPClient(),
            runner: AsyncRunner = ImmediateRunner(),
            userDefaults: AppleUserDefaults = InRamAppleUserDefaults(),
            deviceOrientation: DeviceOrientation = DeviceOrientation(.portrait)
        ) {
            self.httpClient = httpClient
            self.runner = runner
            self.userDefaults = userDefaults
            self.deviceOrientation = deviceOrientation
        }
        
        func sut() -> CitiesScreenViewModel {
            let citiesAPI = CitiesAPI(httpClient: httpClient)
            let citiesStore = CitiesStore(citiesAPI: citiesAPI, runner: runner, userDefaults: userDefaults)
            return .init(citiesStore: citiesStore, deviceOrientation: deviceOrientation)
        }
    }
    
    func test_loadCitiesOk() throws {
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
        XCTAssertEqual("Hurzuf, UA", screen.list.visibleItems.first?.headingText)
        XCTAssertEqual("34.283333, 44.549999", screen.list.visibleItems.first?.subheadText)
    }
    
    func test_onlyLoadsContentOnce() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.hurzuf])))))
        
        screen.onAppear()
        XCTAssertTrue(httpClient.pendingRequests.isEmpty)
    }
    
    func test_loadCitiesFailsAndRetry() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)

        screen.onAppear()
        
        XCTAssertFalse(screen.errorViewModel.isShowing)
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 500))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.errorViewModel.isShowing)
        XCTAssertEqual("Something went wrong", screen.errorViewModel.headingText)
        XCTAssertEqual("Tap to try again", screen.errorViewModel.subheadText)
        
        // tap on error to retry
        screen.tapOnErrorMessage()
        
        XCTAssertFalse(screen.errorViewModel.isShowing)
        XCTAssertTrue(screen.isShowingSpinner)
        
        let newRequest = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, newRequest.urlString)
        XCTAssertTrue(try httpClient.respond(to: newRequest, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.city1])))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("City 1, AA", screen.list.visibleItems.first?.headingText)
    }
    
    func test_sorted() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.sidney, TestData.Cities.denver])
        ))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Denver, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.list.visibleItems[safe: 1]?.headingText)
    }
    
    func test_filterOnlyWhenCitiesAreLoaded() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        screen.onAppear()
        
        _ = try XCTUnwrap(httpClient.pendingRequests.unique())

        screen.searchBarType("")
        XCTAssertTrue(screen.isShowingSpinner)
        
        screen.favoriteFilterButton.tap()
        XCTAssertTrue(screen.isShowingSpinner)
    }
    
    func test_filter() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)
        ))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Alabama, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.list.visibleItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.list.visibleItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems[safe: 3]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.list.visibleItems[safe: 4]?.headingText)
        
        XCTAssertEqual("Filter", screen.searchBar.placeholderText)
        screen.searchBarType("A")
        XCTAssertEqual("A", screen.searchBar.text)
        
        XCTAssertEqual("Alabama, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.list.visibleItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.list.visibleItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems[safe: 3]?.headingText)
        XCTAssertNil(screen.list.visibleItems[safe: 4])
        
        screen.searchBarType("l")
        XCTAssertEqual("Al", screen.searchBar.text)
        
        XCTAssertEqual("Alabama, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.list.visibleItems[safe: 1]?.headingText)
        XCTAssertNil(screen.list.visibleItems[safe: 2])
        
        screen.searchBarType("b")
        XCTAssertEqual("Alb", screen.searchBar.text)
        
        XCTAssertEqual("Albuquerque, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertNil(screen.list.visibleItems[safe: 1])
        
        screen.searchBarTypeDelete()
        XCTAssertEqual("Al", screen.searchBar.text)
        screen.searchBarTypeDelete()
        XCTAssertEqual("A", screen.searchBar.text)
        screen.searchBarTypeDelete()
        XCTAssertEqual("", screen.searchBar.text)
        XCTAssertEqual("Alabama, US", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertEqual("Albuquerque, US", screen.list.visibleItems[safe: 1]?.headingText)
        XCTAssertEqual("Anaheim, US", screen.list.visibleItems[safe: 2]?.headingText)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems[safe: 3]?.headingText)
        XCTAssertEqual("Sidney, AU", screen.list.visibleItems[safe: 4]?.headingText)
        
        screen.searchBarType("s")
        XCTAssertEqual("s", screen.searchBar.text)
        XCTAssertEqual("Sidney, AU", screen.list.visibleItems[safe: 0]?.headingText)
        XCTAssertNil(screen.list.visibleItems[safe: 1])
    }
    
    func test_filterNoResults() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([TestData.Cities.arizona])))))
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems.first?.headingText)
        
        screen.searchBarType("X")
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertTrue(screen.emptyViewModel.isShowing)
        XCTAssertEqual("No cities found", screen.emptyViewModel.headingText)
        XCTAssertEqual("Try adjusting your search", screen.emptyViewModel.subheadText)
        
        screen.searchBarTypeDelete()
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.emptyViewModel.isShowing)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems.first?.headingText)
        
        screen.searchBarType("A")
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.emptyViewModel.isShowing)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems.first?.headingText)
        
        screen.searchBarType("X")
        
        XCTAssertTrue(screen.emptyViewModel.isShowing)
        
        screen.searchBarTypeDelete()
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertFalse(screen.emptyViewModel.isShowing)
        XCTAssertEqual("Arizona, US", screen.list.visibleItems.first?.headingText)
    }
    
    func test_filterByFavorites() throws {
        let make = Make()
        let (screen, httpClient) = (make.sut(), make.httpClient)
        
        XCTAssertFalse(screen.isShowingSpinner)
        
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        XCTAssertEqual("Alabama, US", screen.list.visibleItems.first?.headingText)
        
        XCTAssertFalse(screen.favoriteFilterButton.isSelected)
        
        screen.favoriteFilterButton.tap()
        XCTAssertTrue(screen.favoriteFilterButton.isSelected)
        
        XCTAssertNil(screen.list.visibleItems.first)
        
        screen.favoriteFilterButton.tap()
        XCTAssertFalse(screen.favoriteFilterButton.isSelected)
        
        // add favorite
        let sidneyRow = try XCTUnwrap(screen.list.visibleItems.last)
        XCTAssertEqual("Sidney, AU", sidneyRow.headingText)
        XCTAssertFalse(sidneyRow.favoriteButton.isSelected)
        sidneyRow.favoriteButton.tap()
        XCTAssertTrue(sidneyRow.favoriteButton.isSelected)
        
        // filter favorites
        screen.favoriteFilterButton.tap()
        XCTAssertTrue(screen.favoriteFilterButton.isSelected)
        let favoriteRow = try XCTUnwrap(screen.list.visibleItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
        XCTAssertTrue(favoriteRow.favoriteButton.isSelected)
        
        // unfavorite
        sidneyRow.favoriteButton.tap()
        XCTAssertNil(screen.list.visibleItems.first)
        XCTAssertTrue(screen.emptyViewModel.isShowing)
    }
    
    func test_favoritesPersistence() throws {
        let make1 = Make()
        var (screen, httpClient) = (make1.sut(), make1.httpClient)
        
        screen.onAppear()
        
        var request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        
        // add favorite
        let sidneyRow = try XCTUnwrap(screen.list.visibleItems.last)
        XCTAssertEqual("Sidney, AU", sidneyRow.headingText)
        XCTAssertFalse(sidneyRow.favoriteButton.isSelected)
        sidneyRow.favoriteButton.tap()
        XCTAssertTrue(sidneyRow.favoriteButton.isSelected)
        
        // filter favorites
        screen.favoriteFilterButton.tap()
        var favoriteRow = try XCTUnwrap(screen.list.visibleItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
        XCTAssertTrue(favoriteRow.favoriteButton.isSelected)

        // new run
        
        let make2 = Make(userDefaults: make1.userDefaults)
        (screen, httpClient) = (make2.sut(), make2.httpClient)
        
        screen.onAppear()
        
        request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        
        screen.favoriteFilterButton.tap()
        favoriteRow = try XCTUnwrap(screen.list.visibleItems.unique())
        XCTAssertEqual("Sidney, AU", favoriteRow.headingText)
    }
    
    func test_landscapeLayout() throws {
        let make = Make()
        let (screen, httpClient, deviceOrientation) = (make.sut(), make.httpClient, make.deviceOrientation)
        
        screen.onAppear()
        
        XCTAssertFalse(screen.isShowingMap)
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual(CitiesAPI.citiesGistUrl, request.urlString)
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode(TestData.Cities.filterExample)))))
        
        let sidneyRow = try XCTUnwrap(screen.list.visibleItems.last)
        XCTAssertEqual("Sidney, AU", sidneyRow.headingText)
        
        deviceOrientation.value = .landscape
        
        XCTAssertTrue(screen.isShowingMap)
        XCTAssertTrue(screen.emptyMapViewModel.isShowing)
        XCTAssertEqual("No city selected", screen.emptyMapViewModel.headingText)
        XCTAssertEqual("Select a city on the list", screen.emptyMapViewModel.subheadText)
        
        sidneyRow.tapOnRow()
        
        let sidney = City.from(TestData.Cities.sidney)
        XCTAssertFalse(screen.emptyMapViewModel.isShowing)
        XCTAssertEqual("Sidney", screen.mapViewModel?.pinTitleText)
        try XCTAssertEqualCoordinates(sidney.coordinates, XCTUnwrap(screen.mapViewModel?.pinCoordinates))
        
        sidneyRow.tapOnRow()
        
        XCTAssertTrue(screen.emptyMapViewModel.isShowing)
        XCTAssertNil(screen.mapViewModel)
        
        sidneyRow.tapOnRow()
        XCTAssertFalse(screen.emptyMapViewModel.isShowing)
        XCTAssertEqual("Sidney", screen.mapViewModel?.pinTitleText)
        
        // going portrait and landscape, selected is lost
        deviceOrientation.value = .portrait
        XCTAssertFalse(sidneyRow.isSelected)
        
        deviceOrientation.value = .landscape
        
        XCTAssertTrue(screen.emptyMapViewModel.isShowing)
        XCTAssertNil(screen.mapViewModel)
        
        sidneyRow.tapOnRow()
        XCTAssertTrue(sidneyRow.isSelected)
        XCTAssertFalse(screen.emptyMapViewModel.isShowing)
        XCTAssertEqual("Sidney", screen.mapViewModel?.pinTitleText)
    }
}
