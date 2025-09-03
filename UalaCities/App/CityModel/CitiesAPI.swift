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
    private let logger: Logger
    init(httpClient: HTTPClient, logger: Logger) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func fetchCities(_ completion: @escaping (Result<[CityDTO], Error>) -> Void) {
        let request = HTTPRequest(urlString: Self.citiesGistUrl)
        httpClient.send(request) { result in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    self.logger.log(.error, "unexpected response \(response)")
                    return completion(.failure(.networkingError))
                }
                do {
                    let cities = try JSONDecoder().decode([CityDTO].self, from: response.data ?? .init())
                    completion(.success(cities))
                } catch {
                    self.logger.log(.error, "decodingError: \(error)")
                    completion(.failure(.networkingError))
                }
            case .failure(let error):
                self.logger.log(.error, "httpError: \(error)")
                completion(.failure(.networkingError))
            }

        }
    }
}

struct CityDTO: Codable, Equatable {
    struct Coord: Codable, Equatable {
        var lat: Double
        var lon: Double
    }
    var _id: Int
    var name: String
    var country: String
    var coord: Coord
}
