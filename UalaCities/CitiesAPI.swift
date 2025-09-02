//
//  CitiesAPI.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

class CitiesAPI {
    static let citiesGistUrl = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
    enum Error: Swift.Error {
        case networkingError
    }
    
    private let httpClient: HTTPClient
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchCities(_ completion: @escaping (Result<[City], Error>) -> Void) {
        let request = HTTPRequest(urlString: Self.citiesGistUrl)
        httpClient.send(request) { response in
            do {
                let cities = try JSONDecoder().decode([City].self, from: response.data ?? .init())
                completion(.success(cities))
            } catch {
                // TODO: log
                completion(.failure(.networkingError))
            }
        }
    }
}


struct City: Codable {
    var name: String
}
