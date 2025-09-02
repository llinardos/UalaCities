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
                ProgressView(viewModel.spinnerText)
            } else if viewModel.isShowingError {
                VStack {
                    Text(viewModel.errorHeading).font(.headline)
                    Text(viewModel.errorSubhead).font(.subheadline)
                }
                .onTapGesture { viewModel.onErrorTap() }
            } else if viewModel.isShowingList {
                List(viewModel.citiesListItems, id: \.headingText) { row in
                    Text(row.headingText)
                }
            }
        }
        .onAppear { viewModel.onAppear() }
        
    }
}

#Preview("ok") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 200, data: try! JSONEncoder().encode([City(name: "City 1", country: "AA")]))])))
}

#Preview("error") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 500)])))
}
