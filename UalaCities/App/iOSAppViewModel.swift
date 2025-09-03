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
        case cityDetail(City, CityDetailScreenViewModel)
        
        static func == (lhs: iOSAppViewModel.Route, rhs: iOSAppViewModel.Route) -> Bool {
            switch (lhs, rhs) {
            case let (.cityMap(lCity, _), .cityMap(rCity, _)): return lCity.id == rCity.id
            case (.cityMap, _): return false
            case let (.cityDetail(lCity, _), .cityDetail(rCity, _)): return lCity.id == rCity.id
            case (.cityDetail, _): return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .cityMap(let city, _): hasher.combine(city.id)
            case .cityDetail(let city, _): hasher.combine(city.id)
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
        let citiesScreen = CitiesScreenViewModel(citiesStore: citiesStore, deviceOrientation: UIKitDeviceOrientation())
        self.rootScreen = citiesScreen
        
        citiesScreen.onCitySelected = { [weak self] city in
            guard let self else { return }
            
            let mapScreen = CityMapScreenViewModel(city: city)
            self.path.append(.cityMap(city, mapScreen))
        }
        
        citiesScreen.onCityDetailTapped = { [weak self] city in
            guard let self else { return }
            
            let detailScreen = CityDetailScreenViewModel(city: city)
            self.path.append(.cityDetail(city, detailScreen))
        }
    }
}
