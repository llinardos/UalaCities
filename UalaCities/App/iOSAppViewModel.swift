//
//  iOSApp.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation
import Combine

public class iOSAppViewModel: ObservableObject {
    enum Route: Hashable {
        case cityMap(City, CityMapScreenViewModel)
        
        static func == (lhs: iOSAppViewModel.Route, rhs: iOSAppViewModel.Route) -> Bool {
            switch (lhs, rhs) {
            case let (.cityMap(lCity, lScreen), .cityMap(rCity, rScreen)):
                return lCity.id == rCity.id
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .cityMap(let city, _):
                hasher.combine(city.id)
            }
        }
    }
    var rootScreen: CitiesScreenViewModel
    @Published var path: [Route] = []
    
    public static func prod() -> iOSAppViewModel {
        return .init(httpClient: URLSessionHTTPClient(), runner: GlobalRunner(), userDefaults: RealAppleUserDefaults())
    }
    
    public static func uiTests() -> iOSAppViewModel {
        let userDefaults = RealAppleUserDefaults()
        userDefaults.wipe()
        
        let httpClient: HTTPClient
        if let string = ProcessInfo.processInfo.environment["UITestScenario"], let scenario = UITestScenarios(rawValue: string) {
            switch scenario {
            case .loadCitiesErrorAndRetry:
                let stubbedHttpClient = StubbedHTTPClient([
                    HTTPResponse(statusCode: 500),
                    HTTPResponse(statusCode: 200, data: try! JSONEncoder().encode([
                        CityDTO(_id: 1, name: "City", country: "AA", coord: .init(lat: 1, lon: 1))
                    ])),
                ])
                httpClient = stubbedHttpClient
            }
        } else {
            httpClient = URLSessionHTTPClient()
        }
        
        return .init(httpClient: httpClient, runner: GlobalRunner(), userDefaults: userDefaults)
    }
    
    init(
        httpClient: HTTPClient,
        runner: AsyncRunner,
        userDefaults: AppleUserDefaults
    ) {
        let citiesAPI = CitiesAPI(httpClient: httpClient)
        let citiesStore = CitiesStore(citiesAPI: citiesAPI, runner: runner, userDefaults: userDefaults)
        let citiesScreen = CitiesScreenViewModel(citiesStore: citiesStore)
        self.rootScreen = citiesScreen
        
        citiesScreen.onCitySelected = { [weak self] city in
            guard let self else { return }
            
            let mapScreen = CityMapScreenViewModel(city: city)
            self.path.append(.cityMap(city, mapScreen))
        }
    }
}
