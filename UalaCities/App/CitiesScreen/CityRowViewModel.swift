//
//  CityRowViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class CityRowViewModel: ObservableObject, Identifiable {
    @Published var headingText: String = ""
    @Published var subheadText: String = ""
    @Published var favoriteButtonIsSelected: Bool = false
    private var city: City
    @Published var isSelected: Bool = false
    
    var id: Int { city.id }
    
    private let onFavoriteButtonTap: (() -> Void)
    private let onRowTap: (() -> Void)
    private let onInfoButtonTap: (() -> Void)
        
    init(city: City, isFavorite: Bool, onFavoriteTap: @escaping () -> Void, onRowTap: @escaping () -> Void, onInfoButtonTap: @escaping () -> Void) {
        self.city = city
        self.headingText = "\(city.name), \(city.countryCode)"
        self.subheadText = "\(city.coordinates.latitude), \(city.coordinates.longitude)"
        self.favoriteButtonIsSelected = isFavorite
        self.onFavoriteButtonTap = onFavoriteTap
        self.onRowTap = onRowTap
        self.onInfoButtonTap = onInfoButtonTap
    }
    
    func tapOnFavoriteButtton() {
        onFavoriteButtonTap()
        self.favoriteButtonIsSelected.toggle()
    }
    
    func tapOnRow() {
        self.onRowTap()
    }
    
    func tapOnInfoButton() {
        self.onInfoButtonTap()
    }
}
