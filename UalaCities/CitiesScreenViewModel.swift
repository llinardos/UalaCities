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
    
    @Published var isShowingError: Bool = false
    @Published var errorHeading = "Something went wrong"
    @Published var errorSubhead = "Tap to try again"
    
    @Published var isShowingEmptyView: Bool = false
    @Published var emptyHeadingText = "No cities found"
    @Published var emptySubheadText = "Try adjusting your search"
    
    @Published var isShowingList: Bool = false
    let list = PaginatedListViewModel<CityRowViewModel>(items: [], pageSize: 100, prefetchOffset: 10)
    var citiesListItems: [CityRowViewModel] { list.visibleItems } // TODO: clean, adapted for tests after viewmodel API change
    
    let searchBar = SearchBarViewModel(placeholderText: "Filter")
    var searchBarText: String { searchBar.text }
    var searchBarPlaceholder: String { searchBar.placeholderText } // TODO: clean, adapted for tests after viewmodel API change
    
    @Published var favoriteFilterButtonIsSelected = false
    func onTapFavoriteFilterButton() {
        favoriteFilterButtonIsSelected.toggle()
    }
    
    private let citiesRepo: CitiesRepository
    
    init(httpClient: HTTPClient, runner: AsyncRunner, userDefaults: AppleUserDefaults) {
        self.citiesRepo = CitiesRepository(citiesAPI: CitiesAPI(httpClient: httpClient), runner: runner, userDefaults: userDefaults)
        
        citiesRepo.$state.sink { [weak self] state in
            guard let self else { return}
            
            switch state {
            case .idle: break
            case .loading:
                self.isShowingSpinner = true
                self.isShowingList = false
                self.isShowingError = false
                self.isShowingEmptyView = false
            case .ready(let cities):
                self.isShowingSpinner = false
                self.isShowingError = false
                self.isShowingList = true
                
                self.list.items = cities.map { city in
                    CityRowViewModel(
                        city: city,
                        isFavorite: self.citiesRepo.isFavorite(city),
                        onFavoriteTap: { [weak self] in
                            self?.citiesRepo.toogleFavorite(for: city)
                    }
                ) }
                self.isShowingEmptyView = cities.isEmpty
            case .failed:
                self.isShowingSpinner = false
                self.isShowingList = false
                self.isShowingError = true
            }
        }.store(in: &subscriptions)

        searchBar.$text.sink { [weak self] query in
            self?.citiesRepo.filter(by: query)
        }.store(in: &subscriptions)
        
        $favoriteFilterButtonIsSelected.sink { [weak self] isOn in
            self?.citiesRepo.filterFavorites(isOn)
        }.store(in: &subscriptions)
    }
    
    func onAppear() {
        citiesRepo.load()
    }
    
    func onErrorTap() {
        citiesRepo.load()
    }
    
    func searchBarType(_ text: String) {
        self.searchBar.text += text
    }
    
    func searchBarTypeDelete() {
        self.searchBar.text.removeLast()
    }
}

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
