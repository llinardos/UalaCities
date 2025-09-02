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
    let httpClient: HTTPClient = URLSessionHTTPClient()
    
    func onAppear() {
        let request = HTTPRequest(urlString: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
        httpClient.send(request) { [weak self] response in
            guard let self else { return }
            do {
                let cities = try JSONDecoder().decode([City].self, from: response.data ?? .init())
                self.isShowingList = true
                self.citiesListItems = cities
            } catch {
                
            }
        }
    }
}

struct HTTPRequest {
    var urlString: String
}
struct HTTPResponse {
    var data: Data?
}

protocol HTTPClient {
    func send(_ request: HTTPRequest, _ completion: @escaping (HTTPResponse) -> Void)
}

class URLSessionHTTPClient: HTTPClient {
    func send(_ request: HTTPRequest, _ completion: @escaping (HTTPResponse) -> Void) {
        let urlRequest = URLRequest(url: URL(string: request.urlString)!)
        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            let response = HTTPResponse(data: data)
            DispatchQueue.main.async { completion(response) }
        }.resume()
    }
}

struct City: Decodable {
    var name: String
}
