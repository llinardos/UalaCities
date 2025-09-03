//
//  CityInformationScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class CityInformationScreenViewModel: ObservableObject {
    private let city: City
    
    @Published var titleText: String
    
    @Published var rows: [TitleAndValueRowViewModel] = []
    
    var onCoordinatesTap: (() -> Void)?
    
    init(city: City) {
        self.city = city
        
        self.titleText = "City Information"
        
        rows = [
            .init(title: "Name", value: city.name),
            .init(title: "Country Code", value: city.countryCode),
            .init(title: "Coordinates", value: "\(city.coordinates.latitude), \(city.coordinates.longitude)", action: { [weak self] in self?.onCoordinatesTap?() })
        ]
    }
}
