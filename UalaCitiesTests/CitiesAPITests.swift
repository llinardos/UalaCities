import Foundation
@testable import UalaCities
import XCTest

class CitiesAPITests: XCTestCase {
    func test() throws {
        func send(
            httpResult: Result<HTTPResponse, HTTPError>,
            expectedResult: Result<[City], CitiesAPI.Error>,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            let http = ControlledHTTPClient()
            let api = CitiesAPI(httpClient: http)
            
            let fetched = expectation(description: "fetched")
            
            api.fetchCities { result in
                XCTAssertEqual(expectedResult, result)
                fetched.fulfill()
            }
            
            let request = try XCTUnwrap(http.pendingRequests.unique())
            XCTAssertEqual(request.urlString, CitiesAPI.citiesGistUrl)
            http.respond(to: request, with: httpResult)
            
            wait(for: [fetched])
        }
        
        try send(
            httpResult: .success(.init(statusCode: 200, data: try JSONEncoder().encode([
                TestData.Cities.city1,
                TestData.Cities.city2,
            ]))),
            expectedResult: .success([
                TestData.Cities.city1,
                TestData.Cities.city2
            ])
        )
        
        let cities = (1...400_000).map { City(name: "City \($0)", country: "AA") }
        try send(
            httpResult: .success(.init(statusCode: 200, data: try JSONEncoder().encode(cities))),
            expectedResult: .success(cities)
        )
        
        try send(
            httpResult: .success(.init(statusCode: 200, data: "asd".data(using: .utf8)!)),
            expectedResult: .failure(.networkingError)
        )
        
        try send(
            httpResult: .success(.init(statusCode: 500)),
            expectedResult: .failure(.networkingError)
        )
        
        try send(
            httpResult: .failure(.noHttpResponse),
            expectedResult: .failure(.networkingError)
        )
        
        try send(
            httpResult: .failure(.transportError(nil)),
            expectedResult: .failure(.networkingError)
        )
        
        try send(
            httpResult: .failure(.wrongUrl(nil)),
            expectedResult: .failure(.networkingError)
        )
    }
}
