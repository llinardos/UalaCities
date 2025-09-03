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
        HStack {
            VStack {
                if viewModel.isShowingSpinner {
                    ProgressView(viewModel.spinnerText)
                } else if viewModel.errorViewModel.isShowing {
                    InfoMessageView(viewModel: viewModel.errorViewModel)
                } else if viewModel.isShowingList {
                    VStack {
                        HStack(spacing: 8) {
                            SearchBarView(viewModel: viewModel.searchBar)
                                .padding(.vertical)
                            FavoriteButton(viewModel: viewModel.favoriteFilterButton)
                                .accessibilityIdentifier("FavoriteFilterButton")
                        }
                        .padding(.horizontal)
                        
                        PaginatedListView(viewModel.list) { rowViewModel in
                            CityRowView(viewModel: rowViewModel)
                        }
                        .safeAreaInset(edge: .bottom) {
                            if viewModel.emptyViewModel.isShowing {
                                InfoMessageView(viewModel: viewModel.emptyViewModel)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            if viewModel.isShowingMap {
                VStack {
                    if let mapViewModel = viewModel.mapViewModel {
                        CityMapView(viewModel: mapViewModel, hideNavBar: true)
                    }
                    if viewModel.emptyMapViewModel.isShowing {
                        InfoMessageView(viewModel: viewModel.emptyMapViewModel)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { viewModel.onAppear() }
    }
}
