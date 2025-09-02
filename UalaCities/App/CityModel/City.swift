//
//  City.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation
import CoreLocation

class City: Identifiable {
    let id: Int
    let name: String
    let country: String
    let coordinates: CLLocationCoordinate2D
    
    init(id: Int, name: String, country: String, coordinates: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinates = coordinates
    }
}

extension City {
    static func from(_ dto: CityDTO) -> City {
        City(
            id: dto._id,
            name: dto.name,
            country: dto.country,
            coordinates: .init(latitude: dto.coord.lat, longitude: dto.coord.lon)
        )
    }
}
