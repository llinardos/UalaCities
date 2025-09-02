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
        screen.onAppear()
        
        let request = try XCTUnwrap(httpClient.pendingRequests.unique())
        XCTAssertEqual("https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json", request.urlString)
        
        try httpClient.respond(to: request, with: HTTPResponse(data: JSONEncoder().encode([City(name: "Hurzuf")])))
        
        XCTAssertTrue(screen.isShowingList)
        XCTAssertEqual("Hurzuf", screen.citiesListItems.first?.name)
    }
}

class ControlledHTTPClient: HTTPClient {
    private(set) var pendingRequests: [HTTPRequest] = []
    private var completionById: [UUID: (HTTPResponse) -> Void] = [:]
    func send(_ request: UalaCities.HTTPRequest, _ completion: @escaping (UalaCities.HTTPResponse) -> Void) {
        pendingRequests.append(request)
        completionById[request.id] = completion
    }
    
    func respond(to request: HTTPRequest, with response: HTTPResponse, file: StaticString = #file, line: UInt = #line) {
        guard let completion = completionById[request.id] else {
            XCTFail("no request to complete", file: file, line: line)
            return
        }
        completion(response)
        pendingRequests = pendingRequests.filter { $0.id != request.id }
    }
}

extension Array {
    func unique() -> Element? {
        guard count == 1 else { return nil }
        return first
    }
}
