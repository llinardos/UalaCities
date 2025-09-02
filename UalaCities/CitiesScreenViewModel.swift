//
//  CitiesScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

class CitiesScreenViewModel: ObservableObject {
    @Published var isShowingList: Bool = false
    @Published var citiesListItems: [City] = []
    let httpClient = HTTPClient()
    
    func onAppear() {
        httpClient.fetchCities() { [weak self] cities in
            guard let self else { return }
            self.isShowingList = true
            self.citiesListItems = cities
        }
    }
}

struct HTTPRequest {
    var urlString: String
}
struct HTTPResponse {
    var data: Data?
}

class HTTPClient {
    func fetchCities(_ completion: @escaping ([City]) -> Void) {
        let request = HTTPRequest(urlString: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
        let urlRequest = URLRequest(url: URL(string: request.urlString)!)
        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            let response = HTTPResponse(data: data)
            DispatchQueue.main.async {
                do {
                    let cities = try JSONDecoder().decode([City].self, from: response.data ?? .init())
                    completion(cities)
                } catch {
                    
                }
            }
        }.resume()
    }
}

struct City: Decodable {
    var name: String
}
