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
    @Published var citiesListItems: [CityRow] = []
    
    @Published var searchBarText: String = ""
    @Published var searchBarPlaceholder = "Filter"
    
    private let citiesAPI: CitiesAPI
    private var cities: [City] = []
    
    init(httpClient: HTTPClient) {
        self.citiesAPI = CitiesAPI(httpClient: httpClient)
        
        $searchBarText.sink { [weak self] query in
            guard let self else { return }
            
            self.citiesListItems = self.cities
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
                self.citiesListItems = cities
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
