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
    
    @Published var isShowingList: Bool = false
    let list = PaginatedListViewModel<CityRow>(items: [], pageSize: 100, prefetchOffset: 10)
    var citiesListItems: [CityRow] { list.visibleItems }
    
    @Published var searchBarText: String = ""
    @Published var searchBarPlaceholder = "Filter"
    
    private let citiesAPI: CitiesAPI
    private var cities: [City] = []
    
    init(httpClient: HTTPClient) {
        self.citiesAPI = CitiesAPI(httpClient: httpClient)
        
        $searchBarText.sink { [weak self] query in
            guard let self else { return }
            
            self.list.items = self.cities
                .sorted { $0.name < $1.name }
                .filter { $0.name.lowercased().hasPrefix(query.lowercased()) }
                .map { CityRow(city: $0) }
        }.store(in: &subscriptions)
    }
    
    func onAppear() {
        fetchCities()
    }
    
    func onErrorTap() {
        fetchCities()
    }
    
    func searchBarType(_ text: String) {
        self.searchBarText += text
    }
    
    func searchBarTypeDelete() {
        self.searchBarText.removeLast()
    }
    
    private func fetchCities() {
        self.isShowingList = false
        self.isShowingError = false
        self.isShowingSpinner = true
        
        citiesAPI.fetchCities { [weak self] result in
            guard let self else { return }
            
            self.isShowingSpinner = false
            switch result {
            case .success(let cities):
                self.isShowingList = true
                self.cities = cities
                self.list.items = cities
                    .sorted { $0.name < $1.name }
                    .map { CityRow(city: $0) }
            case .failure:
                self.isShowingError = true
            }
        }
    }
}

class CityRow: ObservableObject, Identifiable {
    @Published var headingText: String = ""
    private var city: City
    
    init(city: City) {
        self.city = city
        self.headingText = "\(city.name), \(city.country)"
    }
}

class PaginatedListViewModel<T>: ObservableObject {
    @Published var visibleItems: [T]
    
    var items: [T] {
        didSet {
            visibleItems = Array(items[0..<min(pageSize, items.count)])
        }
    }
    private let pageSize: Int
    private let prefetchOffset: Int
    
    init(items: [T], pageSize: Int, prefetchOffset: Int) {
        self.items = items
        self.pageSize = pageSize
        self.prefetchOffset = prefetchOffset
        visibleItems = Array(items[0..<min(pageSize, items.count)])
    }
    
    func onDidDisplayItemAtIndex(_ index: Int) {
        if visibleItems.count - index <= prefetchOffset {
            visibleItems += items[visibleItems.count..<min(visibleItems.count + pageSize, items.count)]
        }
    }
}
