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
                
        citiesRepo.onError = { [weak self] _ in
            guard let self else { return }
            self.isShowingSpinner = false
            self.isShowingList = false
            self.isShowingError = true
        }
        
        citiesRepo.onLoading = { [weak self] in
            guard let self else { return }
            self.isShowingSpinner = true
            self.isShowingList = false
            self.isShowingError = false
        }
        
        citiesRepo.onCitiesUpdate = { [weak self] cities in
            guard let self else { return }
            self.isShowingSpinner = false
            self.list.items = cities.map { CityRow(city: $0) }
            self.isShowingList = true
            self.isShowingError = false
        }

        $searchBarText.dropFirst().removeDuplicates().sink { [weak self] query in
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

class CitiesRepository {
    private let citiesAPI: CitiesAPI
    private var allCities: [City] = []
    private let runner: AsyncRunner
    
    init(citiesAPI: CitiesAPI, runner: AsyncRunner) {
        self.citiesAPI = citiesAPI
        self.runner = runner
    }
    
    private var query: String = ""
    func filter(by query: String) {
        self.query = query
        refreshList()
    }
    
    var onError: ((CitiesAPI.Error) -> Void)?
    var onLoading: (() -> Void)?
    var onCitiesUpdate: (([City]) -> Void)?
    
    func load() {
        self.onLoading?()
        
        citiesAPI.fetchCities { [weak self] result in
            guard let self else { return }    
            
            switch result {
            case .success(let cities):
                self.allCities = cities.sorted { $0.name < $1.name }
                self.refreshList()
            case .failure(let error):
                self.onError?(error)
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
            self.onCitiesUpdate?($0)
        }
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

protocol AsyncRunner {
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void)
}
struct GlobalRunner: AsyncRunner {
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = bgWork()
            DispatchQueue.main.async {
                mainWork(result)
            }
        }
    }
}
    
struct ImmediateRunner: AsyncRunner { // para tests
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void) {
        let result = bgWork()
        mainWork(result)
    }
}
