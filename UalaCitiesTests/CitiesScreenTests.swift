//
//  CitiesScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

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
        XCTAssertTrue(try httpClient.respond(to: request, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([City(name: "Hurzuf")])))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Hurzuf", screen.citiesListItems.first?.name)
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
        XCTAssertTrue(try httpClient.respond(to: newRequest, with: .success(HTTPResponse(statusCode: 200, data: JSONEncoder().encode([City(name: "City")])))))
        
        XCTAssertFalse(screen.isShowingSpinner)
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("City", screen.citiesListItems.first?.name)
    }
}
