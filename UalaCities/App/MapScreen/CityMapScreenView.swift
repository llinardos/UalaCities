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
    
    var body: some View {
        CityMapView(viewModel: viewModel.cityMapViewModel, hideNavBar: false)
            .navigationTitle(viewModel.titleText)
    }
}
