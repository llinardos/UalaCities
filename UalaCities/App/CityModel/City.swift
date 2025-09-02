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
