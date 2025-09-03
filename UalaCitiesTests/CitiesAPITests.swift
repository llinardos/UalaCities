import Foundation
@testable import UalaCities
import XCTest

class CitiesAPITests: XCTestCase {
    func test_httpResponsesHandling() throws {
        func send(
            httpResult: Result<HTTPResponse, HTTPError>,
            expectedResult: Result<[CityDTO], CitiesAPI.Error>,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            let http = ControlledHTTPClient()
            let api = CitiesAPI(httpClient: http, logger: NoLogger())
            
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
        
        let cities = (1...400_000).map { CityDTO(_id: $0, name: "City \($0)", country: "AA", coord: .init(lat: 1.0, lon: 1.0)) }
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
    
    func test_decodingErrorIsLogged() throws {
        let logger = SpiedLogger()
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http, logger: logger)
        
        let fetched = expectation(description: "fetched")
        
        var result: Result<[CityDTO], CitiesAPI.Error>?
        api.fetchCities {
            result = $0
            fetched.fulfill()
        }
        
        let request = try XCTUnwrap(http.pendingRequests.unique())
        try http.respond(to: request, with: .success(.init(statusCode: 200, data: JSONSerialization.data(withJSONObject: ["foo": "bar"]))))
        
        wait(for: [fetched])
        
        switch try XCTUnwrap(result) {
        case .failure(.networkingError):
            let logEntry = try XCTUnwrap(logger.entries.unique())
            XCTAssertEqual(logEntry.level, .error)
            XCTAssertTrue(logEntry.message.contains("decodingError"))
        default: XCTFail("got \(String(describing: result))")
        }
    }
    
    func test_httpErrorIsLogged() throws {
        let logger = SpiedLogger()
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http, logger: logger)
        
        let fetched = expectation(description: "fetched")
        
        var result: Result<[CityDTO], CitiesAPI.Error>?
        api.fetchCities {
            result = $0
            fetched.fulfill()
        }
        
        let request = try XCTUnwrap(http.pendingRequests.unique())
        http.respond(to: request, with: .failure(.noHttpResponse))
        
        wait(for: [fetched])
        
        switch try XCTUnwrap(result) {
        case .failure(.networkingError):
            let logEntry = try XCTUnwrap(logger.entries.unique())
            XCTAssertEqual(logEntry.level, .error)
            XCTAssertTrue(logEntry.message.contains("httpError"))
            XCTAssertTrue(logEntry.message.contains("noHttpResponse"))
        default: XCTFail("got \(String(describing: result))")
        }
    }
    
    func test_logs500() throws {
        let logger = SpiedLogger()
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http, logger: logger)
        
        let fetched = expectation(description: "fetched")
        
        var result: Result<[CityDTO], CitiesAPI.Error>?
        api.fetchCities {
            result = $0
            fetched.fulfill()
        }
        
        let request = try XCTUnwrap(http.pendingRequests.unique())
        http.respond(to: request, with: .success(.init(statusCode: 500, data: nil)))
        
        wait(for: [fetched])
        
        switch try XCTUnwrap(result) {
        case .failure(.networkingError):
            let logEntry = try XCTUnwrap(logger.entries.unique())
            XCTAssertEqual(logEntry.level, .error)
            XCTAssertTrue(logEntry.fileId.contains("CitiesAPI"))
            XCTAssertEqual(logEntry.function, "fetchCities(_:)")
            XCTAssertTrue(logEntry.message.contains("unexpected response"))
            XCTAssertTrue(logEntry.message.contains("statusCode: 500"))
        default: XCTFail("got \(String(describing: result))")
        }
    }

}
