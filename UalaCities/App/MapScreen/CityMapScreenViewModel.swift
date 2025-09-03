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

class CityMapViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition
    @Published var pinTitleText: String
    @Published var pinCoordinates: CLLocationCoordinate2D
    
    let city: City
    init(city: City, span: CGFloat = 0.05) {
        self.city = city
        
        self.pinTitleText = "\(city.name), \(city.countryCode)"
        self.pinCoordinates = city.coordinates
        self.cameraPosition =  .region(MKCoordinateRegion(
            center: city.coordinates,
            span: .init(latitudeDelta: span, longitudeDelta: span)
        ))
    }
}
