//
//  iOSApp.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation
import Combine

protocol iOSAppScreen {}
extension CitiesScreenViewModel: iOSAppScreen {}

public class iOSAppViewModel: ObservableObject {
    @Published var mainScreen: iOSAppScreen
    private let httpClient: HTTPClient
    
    public init() {
        if let string = ProcessInfo.processInfo.environment["UITests"], string == "true" {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.synchronize()
            }
        }
        if let string = ProcessInfo.processInfo.environment["UITestScenario"], let scenario = UITestScenarios(rawValue: string) {
            switch scenario {
            case .loadCitiesErrorAndRetry:
                let stubbedHttpClient = StubbedHTTPClient([
                    HTTPResponse(statusCode: 500),
                    HTTPResponse(statusCode: 200, data: try! JSONEncoder().encode([
                        CityDTO(_id: 1, name: "City", country: "AA")
                    ])),
                ])
                httpClient = stubbedHttpClient
            }
        } else {
            httpClient = URLSessionHTTPClient()
        }
        
        mainScreen = CitiesScreenViewModel(httpClient: httpClient, runner: GlobalRunner(), userDefaults: RealAppleUserDefaults())
    }
}
