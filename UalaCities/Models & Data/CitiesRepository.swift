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
        case loaded
        case failed
    }
    
    init(citiesAPI: CitiesAPI, runner: AsyncRunner) {
        self.citiesAPI = citiesAPI
        self.runner = runner
    }
    
    private var query: String = ""
    func filter(by query: String) {
        self.query = query
        
        guard case .loaded = state else { return }
        refreshList()
    }
    
    @Published var state: DataState = .idle
    @Published var cities: [City]? = nil

    func load() {
        self.state = .loading
        
        citiesAPI.fetchCities { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let cities):
                self.allCities = cities.sorted { $0.name < $1.name }
                self.state = .loaded
                self.refreshList()
            case .failure:
                // TODO: log
                self.state = .failed
            }
        }
    }
    
    private func refreshList() {
        runner.run(bgWork: {
            if self.query.count == 0 {
                return self.allCities
            } else {
                return self.allCities
                    .filter { $0.name.lowercased().hasPrefix(self.query.lowercased()) }
            }
        }) {
            self.cities = $0
        }
    }
}
