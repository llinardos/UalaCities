//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

final class IntegrationTests: XCTestCase {
    func test_fetch() {
        let citiesApi = CitiesAPI(httpClient: URLSessionHTTPClient())
        let citiesLoaded = expectation(description: "fetched")
        citiesApi.fetchCities() { result in
            switch result {
            case .success(let cities):
                XCTAssertTrue(cities.count > 200_000)
                XCTAssertEqual("Hurzuf", cities.first?.name)
                XCTAssertEqual("Murava", cities.last?.name)
            case .failure:
                XCTFail("expected success but got \(result)")
            }
            citiesLoaded.fulfill()
        }
        wait(for: [citiesLoaded])
    }
}
