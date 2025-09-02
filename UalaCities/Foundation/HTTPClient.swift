//
//  HTTPClient.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

struct HTTPRequest {
    var id = UUID()
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

class ControlledHTTPClient: HTTPClient {
    private(set) var pendingRequests: [HTTPRequest] = []
    private var completionById: [UUID: (HTTPResponse) -> Void] = [:]
    func send(_ request: UalaCities.HTTPRequest, _ completion: @escaping (UalaCities.HTTPResponse) -> Void) {
        pendingRequests.append(request)
        completionById[request.id] = completion
    }
    
    @discardableResult
    func respond(to request: HTTPRequest, with response: HTTPResponse) -> Bool {
        guard let completion = completionById[request.id] else {
            return false
        }
        completion(response)
        pendingRequests = pendingRequests.filter { $0.id != request.id }
        return true
    }
}

class StubbedHTTPClient: HTTPClient {
    private(set) var responses: [HTTPResponse] = []
    
    init(_ responses: [HTTPResponse]) {
        self.responses = responses
    }
    
    func send(_ request: UalaCities.HTTPRequest, _ completion: @escaping (UalaCities.HTTPResponse) -> Void) {
        guard let response = responses.first else { fatalError() }
        responses = Array(responses.dropFirst())
        completion(response)
    }
}
