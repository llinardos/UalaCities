//
//  CitiesScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

class CitiesScreenViewModel: ObservableObject {
    @Published var isShowingSpinner: Bool = false
    @Published var spinnerText = "Loading Cities..."
    
    @Published var isShowingError: Bool = false
    @Published var errorHeading = "Something went wrong"
    @Published var errorSubhead = "Tap to try again"
    
    @Published var isShowingList: Bool = false
    @Published var citiesListItems: [CityRow] = []
    
    private let citiesAPI: CitiesAPI
    
    init(httpClient: HTTPClient) {
        self.citiesAPI = CitiesAPI(httpClient: httpClient)
    }
    
    func onAppear() {
        fetchCities()
    }
    
    func onErrorTap() {
        fetchCities()
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
