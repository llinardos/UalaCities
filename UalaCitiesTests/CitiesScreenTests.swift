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
}
