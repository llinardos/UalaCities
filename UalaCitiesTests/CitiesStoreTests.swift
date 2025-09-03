//
//  CitiesStoreTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 03/09/2025.
//

import XCTest
@testable import UalaCities

class CitiesStoreTests: XCTestCase {
    
    func test_apiErrorIsLogged() throws {
        let logger = SpiedLogger()
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http, logger: logger)
        let store = CitiesStore(citiesAPI: api, runner: ImmediateRunner(), userDefaults: InRamAppleUserDefaults(), logger: logger)
        
        store.setup()
        http.respond(to: try XCTUnwrap(http.pendingRequests.unique()), with: .failure(.noHttpResponse))
        
        XCTAssertEqual(2, logger.entries.count) // store error, and api error
        let logEntry = try XCTUnwrap(logger.entries.filter { $0.fileId.contains("CitiesStore") }.unique())
        XCTAssertTrue(logEntry.message.contains("Error during setup of CitiesStore due to UalaCities.CitiesAPI"))
        XCTAssertTrue(logEntry.message.contains("networkingError"))
    }
    
    func test_filtering() throws{
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http, logger: NoLogger())
        let store = CitiesStore(citiesAPI: api, runner: ImmediateRunner(), userDefaults: InRamAppleUserDefaults(), logger: NoLogger())
        
        store.setup()
        http.respond(to: try XCTUnwrap(http.pendingRequests.unique()), with: .success(.init(statusCode: 200, data: try JSONEncoder().encode(TestData.Cities.filterExample))))
        
        func assertFiltering(by query: String, is expected: [String], file: StaticString = #file, line: UInt = #line) {
            store.filter(by: query)
            if case let .ready(cities) = store.state {
                XCTAssertEqual(expected, cities.map { $0.name })
            } else { XCTFail() }
        }
        
        assertFiltering(by: "", is: ["Alabama", "Albuquerque", "Anaheim", "Arizona", "Sidney"])
        assertFiltering(by: "A", is: ["Alabama", "Albuquerque", "Anaheim", "Arizona"])
        assertFiltering(by: "Al", is: ["Alabama", "Albuquerque"])
        assertFiltering(by: "An", is: ["Anaheim"])
        assertFiltering(by: "Ar", is: ["Arizona"])
        assertFiltering(by: "S", is: ["Sidney"])
        assertFiltering(by: "Sx", is: [])
        assertFiltering(by: "x", is: [])
        assertFiltering(by: "Ala", is: ["Alabama"])
        assertFiltering(by: "!", is: [])
    }
}
