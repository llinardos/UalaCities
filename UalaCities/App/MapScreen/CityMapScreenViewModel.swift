//
//  CityMapScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation
import MapKit
import SwiftUI

class CityMapScreenViewModel: ObservableObject {
    @Published var titleText: String
    let cityMapViewModel: CityMapViewModel
    
    init(city: City, span: CGFloat = 0.05) {
        self.titleText = "City Map"
        self.cityMapViewModel = .init(city: city)
    }
}
