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
    
    private let onFavoriteTapCallback: (() -> Void)
    private let onRowTapCallback: (() -> Void)
    private let onInfoTapCallback: (() -> Void)
        
    init(city: City, isFavorite: Bool, onFavoriteTap: @escaping () -> Void, onRowTap: @escaping () -> Void, onInfoButtonTap: @escaping () -> Void) {
        self.city = city
        self.headingText = "\(city.name), \(city.countryCode)"
        self.subheadText = "\(city.coordinates.latitude), \(city.coordinates.longitude)"
        self.favoriteButtonIsSelected = isFavorite
        self.onFavoriteTapCallback = onFavoriteTap
        self.onRowTapCallback = onRowTap
        self.onInfoTapCallback = onInfoButtonTap
    }
    
    func onFavoriteButtonTap() {
        onFavoriteTapCallback()
        self.favoriteButtonIsSelected.toggle()
    }
    
    func onRowTap() {
        self.onRowTapCallback()
    }
    
    func onInfoTap() {
        self.onInfoTapCallback()
    }
    
    func onInfoButtonTap() {
        self.onInfoTapCallback()
    }
}
