//
//  CitiesRepository.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class CitiesRepository {
    private let citiesAPI: CitiesAPI
    private var allCities: [City] = []
    private let runner: AsyncRunner
    
    enum DataState {
        case idle
        case loading
        case ready([City])
        case failed
    }
    
    init(citiesAPI: CitiesAPI, runner: AsyncRunner) {
        self.citiesAPI = citiesAPI
        self.runner = runner
    }
    
    private var query: String = ""
    func filter(by query: String) {
        self.query = query
        
        guard case .ready = state else { return }
        refreshList { self.state = .ready($0) }
    }
    
    private var isFilteringFavoriter: Bool = false
    func filterFavorites(_ filterFavorites: Bool) {
        self.isFilteringFavoriter = filterFavorites
        
        guard case .ready = state else { return }
        refreshList { self.state = .ready($0) }
    }
    
    @Published var state: DataState = .idle

    func load() {
        self.state = .loading
        
        citiesAPI.fetchCities { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let cities):
                self.allCities = cities.sorted { $0.name < $1.name }
                self.refreshList { self.state = .ready($0) }
            case .failure:
                // TODO: log
                self.state = .failed
            }
        }
    }
    
    private func refreshList(_ completion: @escaping ([City]) -> Void) {
        runner.run(bgWork: {
            let cities = self.isFilteringFavoriter ? [] : self.allCities
            if self.query.count == 0 {
                return cities
            } else {
                return cities
                    .filter { $0.name.lowercased().hasPrefix(self.query.lowercased()) }
            }
        }, mainWork: completion)
    }
}
