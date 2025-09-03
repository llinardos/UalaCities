//
//  UalaCitiesTests.swift
//  UalaCitiesTests
//
//  Created by Leandro Linardos on 01/09/2025.
//

import XCTest
@testable import UalaCities

final class iOSAppTests: XCTestCase {
    class Make {
        let httpClient: ControlledHTTPClient
        let runner: AsyncRunner
        let userDefaults: AppleUserDefaults
        
        init(
            httpClient: ControlledHTTPClient = ControlledHTTPClient(),
            runner: AsyncRunner = ImmediateRunner(),
            userDefaults: AppleUserDefaults = InRamAppleUserDefaults()
        ) {
            self.httpClient = httpClient
            self.runner = runner
            self.userDefaults = userDefaults
        }
        func sut() -> iOSAppViewModel{
            return .init(httpClient: httpClient, runner: runner, userDefaults: userDefaults)
        }
    }
    
    func test_beginsWithCitiesScreen() {
        let app = Make().sut()
        XCTAssertTrue((app.rootScreen as Any) is CitiesScreenViewModel)
    }
    
    func test_goesToCityMapScreen() throws {
        let make = Make()
        let (app, httpClient) = (make.sut(), make.httpClient)
        
        let citiesScreen = app.rootScreen
        citiesScreen.onAppear()
        
        httpClient.respond(to: try XCTUnwrap(httpClient.pendingRequests.unique()), with: .success(.init(statusCode: 200, data: try? JSONEncoder().encode([TestData.Cities.alabama]))))
        
        citiesScreen.citiesListItems.first?.onRowTap()
        
        guard case let .cityMap(_, mapScreenViewModel) = app.path.last else { return XCTFail() }
        XCTAssertEqual("Alabama, US", mapScreenViewModel.titleText)
    }
    
    func test_goesToInfoFromCitiesScreen() throws {
        let make = Make()
        let (app, httpClient) = (make.sut(), make.httpClient)
        
        let citiesScreen = app.rootScreen
        citiesScreen.onAppear()
        
        httpClient.respond(to: try XCTUnwrap(httpClient.pendingRequests.unique()), with: .success(.init(statusCode: 200, data: try? JSONEncoder().encode([TestData.Cities.alabama]))))
        
        citiesScreen.citiesListItems.first?.onInfoTap()
        
        guard case let .cityInformation(_, infoScreenViewModel) = app.path.last else { return XCTFail() }
        XCTAssertEqual("City Information", infoScreenViewModel.titleText)
        
        infoScreenViewModel.rows.first(where: { $0.titleText == "Coordinates" })?.tap()
        guard case .cityMap = app.path.last else { return XCTFail() }
    }
}
