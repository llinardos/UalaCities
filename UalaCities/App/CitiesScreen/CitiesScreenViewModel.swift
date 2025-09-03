//
//  CitiesScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation
import Combine

class CitiesScreenViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isShowingSpinner: Bool = false
    @Published var spinnerText = "Loading Cities..."
    
    lazy var errorViewModel = InfoMessageViewModel(iconSystemName: "exclamationmark.triangle", headingText: "Something went wrong", subheadText: "Tap to try again", onTap: { [weak self] in self?.tapOnErrorMessage() })
    lazy var emptyViewModel = InfoMessageViewModel(iconSystemName: "magnifyingglass", headingText: "No cities found", subheadText: "Try adjusting your search")
    lazy var emptyMapViewModel = InfoMessageViewModel(iconSystemName: "hand.tap", headingText: "No city selected", subheadText: "Select a city on the list")
    
    
    @Published var isShowingList: Bool = false
    lazy var list = PaginatedListViewModel<City, CityRowViewModel>(items: [], pageSize: 100, prefetchOffset: 10) { city in
        CityRowViewModel(
            city: city,
            isFavorite: self.citiesStore.isFavorite(city),
            onFavoriteTap: { [weak self] in self?.citiesStore.toogleFavorite(for: city) },
            onRowTap: { [weak self] in self?.handleCitySelection(city) },
            onInfoButtonTap: { [weak self] in self?.onCityInfoButtonTapped?(city) }
        )
    }
    
    let searchBar = SearchBarViewModel(placeholderText: "Filter")

    lazy var favoriteFilterButton = FavoriteButtonViewModel { [weak self] in self?.citiesStore.enableFavoritesFilter($0) }
    
    private let citiesStore: CitiesStore
    
    private let deviceOrientation: DeviceOrientation
    @Published var isShowingMap: Bool = false
    @Published var mapViewModel: CityMapViewModel?
    
    @Published private var selectedCity: City?
    private var selectedRowVM: CityRowViewModel?
    
    var onCitySelected: ((City) -> Void)?
    var onCityInfoButtonTapped: ((City) -> Void)?
    
    init(citiesStore: CitiesStore, deviceOrientation: DeviceOrientation) {
        self.citiesStore = citiesStore
        self.deviceOrientation = deviceOrientation
        
        citiesStore.$state.sink { [weak self] state in
            guard let self else { return}
            
            switch state {
            case .idle: break
            case .loading:
                self.isShowingSpinner = true
                self.isShowingList = false
                self.errorViewModel.isShowing = false
                self.emptyViewModel.isShowing = false
            case .ready(let cities):
                self.isShowingSpinner = false
                self.errorViewModel.isShowing = false
                self.isShowingList = true
                self.list.items = cities
                self.emptyViewModel.isShowing = cities.isEmpty
            case .failed:
                self.isShowingSpinner = false
                self.isShowingList = false
                self.errorViewModel.isShowing = true
                self.emptyViewModel.isShowing = false
            }
        }.store(in: &subscriptions)

        searchBar.$text.sink { [weak self] query in
            self?.citiesStore.filter(by: query)
        }.store(in: &subscriptions)
                
        deviceOrientation.$value.sink { [weak self] value in
            guard let self else { return }
            self.isShowingMap = value == .landscape
            self.selectedCity = nil
        }.store(in: &subscriptions)
        
        $selectedCity.sink { [weak self] selectedCity in
            guard let self else { return }
            
            selectedRowVM?.isSelected = false
            selectedRowVM = self.list.visibleItems.first(where: { $0.id == selectedCity?.id })
            selectedRowVM?.isSelected = true
            
            if let selectedCity {
                self.emptyMapViewModel.isShowing = false
                self.mapViewModel = .init(city: selectedCity)
            } else {
                self.emptyMapViewModel.isShowing = true
                self.mapViewModel = nil
            }
        }.store(in: &subscriptions)
    }
    
    func onAppear() {
        citiesStore.setup()
    }
    
    func tapOnErrorMessage() {
        citiesStore.setup()
    }
    
    func searchBarType(_ text: String) {
        self.searchBar.text += text
    }
    
    func searchBarTypeDelete() {
        self.searchBar.text.removeLast()
    }
    
    private func handleCitySelection(_ city: City) {
        if self.deviceOrientation.value == .landscape {
            if selectedCity?.id == city.id {
                selectedCity = nil
            } else {
                selectedCity = city
            }
        } else {
            onCitySelected?(city)
        }
    }
}
