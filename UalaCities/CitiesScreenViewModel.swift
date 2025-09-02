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
    private let runner: AsyncRunner
    
    init(httpClient: HTTPClient, runner: AsyncRunner) {
        self.citiesAPI = CitiesAPI(httpClient: httpClient)
        self.runner = runner
        
        $searchBarText.removeDuplicates().sink { [weak self] query in
            self?.refreshList(query)
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
    
    private func refreshList(_ query: String? = nil) {
        runner.run(bgWork: {
            let query = query ?? self.searchBarText
            if query.count == 0 {
                return self.cities
                    .map { CityRow(city: $0) }
            } else {
                return self.cities
                    .filter { $0.name.lowercased().hasPrefix(query.lowercased()) }
                    .map { CityRow(city: $0) }
            }
        }) {
            self.list.items = $0
        }
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
                self.cities = cities.sorted { $0.name < $1.name }
                self.refreshList()
            case .failure:
                self.isShowingError = true
            }
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
