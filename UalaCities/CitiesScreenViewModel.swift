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
    
    private let citiesRepo: CitiesRepository
    
    init(httpClient: HTTPClient, runner: AsyncRunner) {
        self.citiesRepo = CitiesRepository(citiesAPI: CitiesAPI(httpClient: httpClient), runner: runner)
        
        citiesRepo.$state.sink { [weak self] state in
            guard let self else { return}
            
            switch state {
            case .idle: break
            case .loading:
                self.isShowingSpinner = true
                self.isShowingList = false
                self.isShowingError = false
            case .loaded(let cities):
                self.isShowingSpinner = false
                self.list.items = cities.map { CityRow(city: $0) }
                self.isShowingList = true
                self.isShowingError = false
            case .failed:
                self.isShowingSpinner = false
                self.isShowingList = false
                self.isShowingError = true
            }
        }.store(in: &subscriptions)

        $searchBarText.sink { [weak self] query in
            self?.citiesRepo.filter(by: query)
        }.store(in: &subscriptions)
    }
    
    func onAppear() {
        citiesRepo.load()
    }
    
    func onErrorTap() {
        citiesRepo.load()
    }
    
    func searchBarType(_ text: String) {
        self.searchBarText += text
    }
    
    func searchBarTypeDelete() {
        self.searchBarText.removeLast()
    }
}

class CityRow: ObservableObject, Identifiable {
    @Published var headingText: String = ""
    private var city: City
    
    var id: Int { city._id }
    
    init(city: City) {
        self.city = city
        self.headingText = "\(city.name), \(city.country)"
    }
}
