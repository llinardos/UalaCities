//
//  UITestScenarios.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

enum UITestScenarios: String {
    case loadCitiesErrorAndRetry
    
    func setup(_ stubbedHTTPClient: StubbedHTTPClient) {
        switch self {
        case .loadCitiesErrorAndRetry:
            stubbedHTTPClient.setup([
                HTTPResponse(statusCode: 500),
                HTTPResponse(statusCode: 200, data: try! JSONEncoder().encode([
                    CityDTO(_id: 1, name: "City", country: "AA", coord: .init(lat: 1, lon: 1))
                ])),
            ])
        }
    }
}

class TestData {
    class Cities {
        static var city1 = CityDTO(_id: 1, name: "City 1", country: "AA", coord: .init(lat: 1.0, lon: 1.0))
        static var city2 = CityDTO(_id: 2, name: "City 2", country: "BB", coord: .init(lat: 2.0, lon: 2.0))
        static var hurzuf = CityDTO(_id: 10, name: "Hurzuf", country: "UA", coord: .init(lat: 34.283333, lon: 44.549999))
        static var denver = CityDTO(_id: 11, name: "Denver", country: "US", coord: .init(lat: -81.0298, lon: 35.53125))
        static var sidney = CityDTO(_id: 12, name: "Sidney", country: "AU", coord: .init(lat: -99.079689, lon: 49.900028))
        static var alabama = CityDTO(_id: 13, name: "Alabama", country: "US", coord: .init(lat: -86.750259, lon: 32.750408))
        static var albuquerque = CityDTO(_id: 14, name: "Albuquerque", country: "US", coord: .init(lat: -106.642799, lon: 35.161991))
        static var anaheim = CityDTO(_id: 15, name: "Anaheim", country: "US", coord: .init(lat: -117.914497, lon: 33.835289))
        static var arizona = CityDTO(_id: 16, name: "Arizona", country: "US", coord: .init(lat: -111.670959, lon: 32.75589))
        static var filterExample = [alabama, albuquerque, anaheim, arizona, sidney]
    }
}
