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
    
    init(viewModel: CityMapScreenViewModel, showTitle: Bool = true) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        CityMapView(viewModel: viewModel.cityMapViewModel, hideNavBar: false)
            .navigationTitle(viewModel.titleText)
    }
}

struct CityMapView: View {
    @ObservedObject var viewModel: CityMapViewModel
    private let hideNavBar: Bool
    
    init(viewModel: CityMapViewModel, hideNavBar: Bool) {
        self.viewModel = viewModel
        self.hideNavBar = hideNavBar
    }
    
    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            Marker(viewModel.pinTitleText, coordinate: viewModel.pinCoordinates)
        }
        .navigationBarHidden(hideNavBar)
    }
}
