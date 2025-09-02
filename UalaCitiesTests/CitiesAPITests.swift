import Foundation
@testable import UalaCities
import XCTest

class CitiesAPITests: XCTestCase {
    func test() throws {
        func send(
            response: HTTPResponse,
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
            http.respond(to: request, with: response)
            
            wait(for: [fetched])
        }
        
        try send(
            response: .init(statusCode: 200, data: try JSONEncoder().encode([City(name: "City 1"), City(name: "City 2")])),
            expectedResult: .success([.init(name: "City 1"), .init(name: "City 2")])
        )
        
        try send(
            response: .init(statusCode: 200, data: "asd".data(using: .utf8)!),
            expectedResult: .failure(.networkingError)
        )
        
        try send(
            response: .init(statusCode: 500),
            expectedResult: .failure(.networkingError)
        )
    }
}
