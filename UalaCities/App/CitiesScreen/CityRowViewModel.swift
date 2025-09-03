//
//  CityRowViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation
import Combine

class CityRowViewModel: ObservableObject, Identifiable {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var headingText: String = ""
    @Published var subheadText: String = ""
    lazy var favoriteButton = FavoriteButtonViewModel { [weak self] _ in self?.onFavoriteButtonTap() }
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
        self.onFavoriteButtonTap = onFavoriteTap
        self.onRowTap = onRowTap
        self.onInfoButtonTap = onInfoButtonTap
        self.favoriteButton.isSelected = isFavorite
    }
        
    func tapOnRow() {
        self.onRowTap()
    }
    
    func tapOnInfoButton() {
        self.onInfoButtonTap()
    }
}
