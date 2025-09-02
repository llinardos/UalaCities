//
//  CityMapScreenView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI
import MapKit

struct CityMapScreenView: View {
    @ObservedObject var viewModel: CityMapScreenViewModel
    
    init(viewModel: CityMapScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            Marker(viewModel.pinTitleText, coordinate: viewModel.pinCoordinates)
        }
        .navigationTitle(viewModel.titleText)
    }
}
