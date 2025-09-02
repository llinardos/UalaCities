//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

final class IntegrationTests: XCTestCase {
    func testFetchCities() {
        let httpClient = URLSessionHTTPClient()
        let request = HTTPRequest(urlString: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
        let citiesLoaded = expectation(description: "fetched")
        httpClient.send(request) { response in
            do {
                let cities = try JSONDecoder().decode([City].self, from: response.data ?? .init())
                XCTAssertTrue(cities.count > 200_000)
                XCTAssertEqual("Hurzuf", cities.first?.name)
                XCTAssertEqual("Murava", cities.last?.name)
            } catch {
                XCTFail("expected success but got \(response)")
            }
            citiesLoaded.fulfill()
        }
        wait(for: [citiesLoaded])
    }
}
