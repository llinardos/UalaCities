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
    lazy var list = PaginatedListViewModel<City, CityRowViewModel>(items: [], pageSize: 100, prefetchOffset: 10) { city in
        CityRowViewModel(
            city: city,
            isFavorite: self.citiesStore.isFavorite(city),
            onFavoriteTap: { [weak self] in self?.citiesStore.toogleFavorite(for: city) },
            onRowTap: { [weak self] in self?.onCitySelected(city) },
            onInfoButtonTap: { [weak self] in self?.onCityInfoButtonTapped?(city) }
        )
    }
    var citiesListItems: [CityRowViewModel] { list.visibleItems } // TODO: clean, adapted for tests after viewmodel API change
    
    let searchBar = SearchBarViewModel(placeholderText: "Filter")
    var searchBarText: String { searchBar.text }
    var searchBarPlaceholder: String { searchBar.placeholderText } // TODO: clean, adapted for tests after viewmodel API change
    
    @Published var favoriteFilterButtonIsSelected = false
    func onTapFavoriteFilterButton() {
        favoriteFilterButtonIsSelected.toggle()
    }
    
    private let citiesStore: CitiesStore
    
    private let deviceOrientation: DeviceOrientation
    @Published var isShowingMap: Bool = false
    @Published var mapViewModel: CityMapViewModel?
    @Published var isShowingMapEmptyView = false
    @Published var mapEmptyHeadingText = "No City Selected"
    @Published var mapEmptySubheadText = "Select a City on the List"
    
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
                self.isShowingError = false
                self.isShowingEmptyView = false
            case .ready(let cities):
                self.isShowingSpinner = false
                self.isShowingError = false
                self.isShowingList = true
                self.list.items = cities
                self.isShowingEmptyView = cities.isEmpty
            case .failed:
                self.isShowingSpinner = false
                self.isShowingList = false
                self.isShowingError = true
            }
        }.store(in: &subscriptions)

        searchBar.$text.sink { [weak self] query in
            self?.citiesStore.filter(by: query)
        }.store(in: &subscriptions)
        
        $favoriteFilterButtonIsSelected.sink { [weak self] isOn in
            self?.citiesStore.enableFavoritesFilter(isOn)
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
                self.isShowingMapEmptyView = false
                self.mapViewModel = .init(city: selectedCity)
            } else {
                self.isShowingMapEmptyView = true
                self.mapViewModel = nil
            }
        }.store(in: &subscriptions)
    }
    
    func onAppear() {
        citiesStore.setup()
    }
    
    func onErrorTap() {
        citiesStore.setup()
    }
    
    func searchBarType(_ text: String) {
        self.searchBar.text += text
    }
    
    func searchBarTypeDelete() {
        self.searchBar.text.removeLast()
    }
    
    private func onCitySelected(_ city: City) {
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


import UIKit

class DeviceOrientation { // TODO: move
    enum Value { case landscape, portrait }
    @Published var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

class UIKitDeviceOrientation: DeviceOrientation {
    private var cancellable: AnyCancellable?
    init() {
        super.init(.from(UIDevice.current))
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                self.value = .from(UIDevice.current)
            }
    }
}

extension DeviceOrientation.Value {
    static func from(_ device: UIDevice) -> DeviceOrientation.Value {
        UIDevice.current.orientation.isLandscape ? .landscape : .portrait
    }
}
