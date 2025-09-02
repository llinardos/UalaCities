//
//  CityRowViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class CityRowViewModel: ObservableObject, Identifiable {
    @Published var headingText: String = ""
    @Published var favoriteButtonIsSelected: Bool = false
    private var city: City
    
    var id: Int { city._id }
    
    var onFavoriteTap: (() -> Void)?
    
    init(city: City, isFavorite: Bool, onFavoriteTap: @escaping () -> Void) {
        self.city = city
        self.headingText = "\(city.name), \(city.country)"
        self.favoriteButtonIsSelected = isFavorite
        self.onFavoriteTap = onFavoriteTap
    }
    
    func onFavoriteButtonTap() {
        onFavoriteTap?()
        self.favoriteButtonIsSelected.toggle()
    }
}
