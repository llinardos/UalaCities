//
//  UalaCitiesApp.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import SwiftUI
import UalaCities

@main
struct UalaCitiesApp: App {
    let viewModel = iOSAppViewModel()
    var body: some Scene {
        iOSAppScene(viewModel: viewModel)
    }
}
