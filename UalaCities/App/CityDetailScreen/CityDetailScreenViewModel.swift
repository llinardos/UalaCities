//
//  CityDetailScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class CityDetailScreenViewModel: ObservableObject {
    private let city: City
    
    @Published var titleText: String
    
    init(city: City) {
        self.city = city
        
        self.titleText = "\(city.name), \(city.country)"
    }
}
