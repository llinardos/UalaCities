//
//  CitiesScreenTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

class CitiesScreenTests: XCTestCase {
    func testLoadCitiesOk() {
        let screen = CitiesScreenViewModel()
        screen.onAppear()
        
        let listShown = expectation(description: "list of cities shown")
        Task {
            for await value in screen.$isShowingList.values where value == true {
                listShown.fulfill()
                break
            }
        }
        wait(for: [listShown], timeout: 2)
        
        XCTAssertEqual("Hurzuf", screen.citiesListItems.first?.name)
    }
}
