//
//  HTTPClient.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

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
