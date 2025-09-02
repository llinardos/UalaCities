//
//  ContentView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import SwiftUI

struct CitiesScreenView: View {
    @ObservedObject var viewModel: CitiesScreenViewModel
    
    init(viewModel: CitiesScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.isShowingSpinner {
                ProgressView()
            } else if viewModel.isShowingList {
                List(viewModel.citiesListItems, id: \.name) { city in
                    Text(city.name)
                }
            }
        }
        .onAppear { viewModel.onAppear() }
        
    }
}

#Preview {
    CitiesScreenView(viewModel: .init(httpClient: URLSessionHTTPClient()))
}
