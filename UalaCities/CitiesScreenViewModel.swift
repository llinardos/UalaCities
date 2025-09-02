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
    @Published var citiesListItems: [City] = []
    
    let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
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
        let request = HTTPRequest(urlString: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
        httpClient.send(request) { [weak self] response in
            guard let self else { return }
            self.isShowingSpinner = false
            do {
                let cities = try JSONDecoder().decode([City].self, from: response.data ?? .init())
                self.isShowingList = true
                self.citiesListItems = cities
            } catch {
                self.isShowingError = true
            }
        }
    }
}

struct City: Codable {
    var name: String
}
