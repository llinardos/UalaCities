//
//  CityInformationScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class CityInformationScreenViewModel: ObservableObject {
    class TitleAndValueRowViewModel: ObservableObject, Identifiable {
        @Published var titleText: String
        @Published var valueText: String
        @Published var isShowingArrow: Bool
        
        private var action: (() -> Void)?
        
        init(title: String, value: String, action: (() -> Void)? = nil) {
            self.titleText = title
            self.valueText = value
            self.action = action
            self.isShowingArrow = action != nil
        }
        
        func tap() {
            action?()
        }
    }
    
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
