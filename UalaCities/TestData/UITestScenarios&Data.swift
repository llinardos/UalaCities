//
//  UITestScenarios.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

enum UITestScenarios: String {
    case loadCitiesErrorAndRetry
}

class TestData {
    class Cities {
        static var city1 = CityDTO(_id: 1, name: "City 1", country: "AA")
        static var city2 = CityDTO(_id: 2, name: "City 2", country: "BB")
        static var hurzuf = CityDTO(_id: 10, name: "Hurzuf", country: "UA")
        static var denver = CityDTO(_id: 11, name: "Denver", country: "US")
        static var sidney = CityDTO(_id: 12, name: "Sidney", country: "AU")
        static var alabama = CityDTO(_id: 13, name: "Alabama", country: "US")
        static var albuquerque = CityDTO(_id: 14, name: "Albuquerque", country: "US")
        static var anaheim = CityDTO(_id: 15, name: "Anaheim", country: "US")
        static var arizona = CityDTO(_id: 16, name: "Arizona", country: "US")
        static var filterExample = [alabama, albuquerque, anaheim, arizona, sidney]
    }
}
