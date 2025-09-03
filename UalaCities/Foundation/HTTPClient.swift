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
    var statusCode: Int
    var data: Data? = nil
}
enum HTTPError: Swift.Error {
    case wrongUrl(String?)
    case noHttpResponse
    case transportError(Swift.Error?)
}

protocol HTTPClient {
    func send(_ request: HTTPRequest, _ completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void)
}

class URLSessionHTTPClient: HTTPClient {
    func send(_ request: HTTPRequest, _ completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void) {
        guard let url = URL(string: request.urlString) else {
            return completion(.failure(.wrongUrl(request.urlString)))
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { (data, urlSessionResponse, error) in
            if let error {
                return completion(.failure(.transportError(error)))
            }
            guard let statusCode = (urlSessionResponse as? HTTPURLResponse)?.statusCode else {
                return completion(.failure(.noHttpResponse))
            }
            let response = HTTPResponse(statusCode: statusCode, data: data)
            DispatchQueue.main.async { completion(.success(response)) }
        }.resume()
    }
}

class ControlledHTTPClient: HTTPClient {
    private(set) var pendingRequests: [HTTPRequest] = []
    private var completionById: [UUID: (Result<HTTPResponse, HTTPError>) -> Void] = [:]
    func send(_ request: HTTPRequest, _ completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void) {
        pendingRequests.append(request)
        completionById[request.id] = completion
    }
    
    @discardableResult
    func respond(to request: HTTPRequest, with response: Result<HTTPResponse, HTTPError>) -> Bool {
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
    
    func setup(_ responses: [HTTPResponse]) {
        self.responses = responses
    }
    
    func send(_ request: HTTPRequest, _ completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void) {
        guard let response = responses.first else { fatalError() }
        responses = Array(responses.dropFirst())
        completion(.success(response))
    }
}

class DummyHTTPClient: HTTPClient {
    func send(_ request: HTTPRequest, _ completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void) {}
}
