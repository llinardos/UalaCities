//
//  CitiesStore.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class CitiesStore {
    private let citiesAPI: CitiesAPI
    private var allCities: [City] = []
    private let runner: AsyncRunner
    private let userDefaults: AppleUserDefaults
    private let favoritesIdsInUserDefaultsKey = "favoritesCityIds"
    
    enum CitiesState {
        case idle
        case loading
        case ready([City])
        case failed
    }
    
    @Published var state: CitiesState = .idle

    init(citiesAPI: CitiesAPI, runner: AsyncRunner, userDefaults: AppleUserDefaults) {
        self.citiesAPI = citiesAPI
        self.runner = runner
        self.userDefaults = userDefaults
    }
    
    private var query: String = ""
    func filter(by query: String) {
        self.query = query
        
        guard case .ready = state else { return }
        refreshList()
    }
    
    private var isFilteringFavorites: Bool = false
    func enableFavoritesFilter(_ isEnabled: Bool) {
        self.isFilteringFavorites = isEnabled
        
        guard case .ready = state else { return }
        refreshList()
    }
    
    private var favoriteCities: [City] = []
    func toogleFavorite(for city: City) {
        if favoriteCities.contains(where: { $0.id == city.id }) {
            favoriteCities.removeAll(where: { $0.id == city.id })
        } else {
            favoriteCities.append(city)
        }
        let favoriteIds: [Int] = favoriteCities.map { $0.id }
        userDefaults.set(favoriteIds, forKey: favoritesIdsInUserDefaultsKey)
        refreshList()
    }
    
    func isFavorite(_ city: City) -> Bool {
        favoriteCities.contains(where: { $0.id == city.id })
    }

    func setup() {
        switch state {
        case .failed, .idle: break
        case .loading, .ready: return
        }
        
        self.state = .loading
        
        citiesAPI.fetchCities { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let cities):
                self.allCities = cities
                    .map { .from($0) }
                    .sorted { $0.name < $1.name }
                if let favoritesIds = self.userDefaults.array(forKey: self.favoritesIdsInUserDefaultsKey) as? [Int] {
                    self.favoriteCities = self.allCities.filter { favoritesIds.contains($0.id) }
                }
                self.refreshList()
            case .failure:
                // TODO: log
                self.state = .failed
            }
        }
    }
    
    private func refreshList() {
        runner.run(bgWork: {
            let cities = self.isFilteringFavorites ? self.favoriteCities : self.allCities
            if self.query.count == 0 {
                return cities
            } else {
                return cities
                    .filter { $0.name.lowercased().hasPrefix(self.query.lowercased()) }
            }
        }, mainWork: {
            self.state = .ready($0)
        })
    }
}

extension CitiesStore {
    static func stubbed(state: CitiesStore.CitiesState) -> CitiesStore {
        let store = CitiesStore(citiesAPI: CitiesAPI(httpClient: DummyHTTPClient()), runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults())
//        store.state = state
        return store
    }
}
