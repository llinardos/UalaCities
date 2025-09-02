//
//  City.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class City: Identifiable {
    let id: Int
    let name: String
    let country: String
    
    init(id: Int, name: String, country: String) {
        self.id = id
        self.name = name
        self.country = country
    }
}
