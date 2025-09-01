//
//  CitiesScreenViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation

class CitiesScreenViewModel: ObservableObject {
    @Published var isShowingList: Bool = false
    @Published var citiesListItems: [City] = []
    func onAppear() {
        
    }
}

struct City {
    var name: String
}
