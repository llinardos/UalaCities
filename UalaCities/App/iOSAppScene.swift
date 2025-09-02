//
//  iOSAppScene.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import SwiftUI

public struct iOSAppScene: Scene {
    @ObservedObject var viewModel: iOSAppViewModel
    
    public init(viewModel: iOSAppViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some Scene {
        WindowGroup {
            NavigationStack(path: $viewModel.path) {
                CitiesScreenView(viewModel: viewModel.rootScreen)
                    .navigationDestination(for: iOSAppViewModel.Route.self) { item in
                        switch item {
                        case .cityMap(_, let screenViewModel):
                            CityMapScreenView(viewModel: screenViewModel)
                        }
                    }
            }
        }
    }
}
