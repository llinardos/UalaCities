//
//  CityDetailScreenView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct CityDetailScreenView: View {
    @ObservedObject var viewModel: CityDetailScreenViewModel
    
    init(viewModel: CityDetailScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {}
            .navigationTitle(viewModel.titleText)
    }
}
