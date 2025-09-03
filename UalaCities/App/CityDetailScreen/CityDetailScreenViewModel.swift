//
//  CityDetailScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class CityDetailScreenViewModel: ObservableObject {
    class TitleAndValueRowViewModel: ObservableObject, Identifiable {
        @Published var titleText: String
        @Published var valueText: String
        
        init(title: String, value: String) {
            self.titleText = title
            self.valueText = value
        }
    }
    
    private let city: City
    
    @Published var titleText: String
    
    @Published var rows: [TitleAndValueRowViewModel]
    
    init(city: City) {
        self.city = city
        
        self.titleText = "City Information"
        rows = [
            .init(title: "Name", value: city.name),
            .init(title: "Country Code", value: city.country),
            .init(title: "Coordinates", value: "\(city.coordinates.latitude), \(city.coordinates.longitude)")
        ]
    }
}
