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
            if let screen = viewModel.mainScreen as? CitiesScreenViewModel {
                CitiesScreenView(viewModel: screen)
            } else {
                fatalError("No View for screen: \(viewModel.mainScreen)")
            }
        }
    }
}
