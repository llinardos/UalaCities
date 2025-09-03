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
    
    var onFavoriteTap: (() -> Void)
    var onTap: (() -> Void)
        
    init(city: City, isFavorite: Bool, onFavoriteTap: @escaping () -> Void, onRowTap: @escaping () -> Void) {
        self.city = city
        self.headingText = "\(city.name), \(city.country)"
        self.subheadText = "\(city.coordinates.latitude), \(city.coordinates.longitude)"
        self.favoriteButtonIsSelected = isFavorite
        self.onFavoriteTap = onFavoriteTap
        self.onTap = onRowTap
    }
    
    func onFavoriteButtonTap() {
        onFavoriteTap()
        self.favoriteButtonIsSelected.toggle()
    }
    
    func onRowTap() {
        self.onTap()
    }
}
