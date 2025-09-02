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
    @Published var cameraPosition: MapCameraPosition
    @Published var pinTitleText: String
    @Published var pinCoordinates: CLLocationCoordinate2D
    
    let city: City
    init(city: City, span: CGFloat = 0.05) {
        self.city = city
        
        self.titleText = "\(city.name), \(city.country)"
        self.pinTitleText = city.name
        self.pinCoordinates = city.coordinates
        self.cameraPosition =  .region(MKCoordinateRegion(
            center: city.coordinates,
            span: .init(latitudeDelta: span, longitudeDelta: span)
        ))
    }
}
