//
//  CityMapView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI
import Foundation
import MapKit

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
