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
                } else if viewModel.isShowingError {
                    VStack {
                        Text(viewModel.errorHeading).font(.headline)
                        Text(viewModel.errorSubhead).font(.subheadline)
                    }
                    .onTapGesture { viewModel.tapOnErrorMessage() }
                } else if viewModel.isShowingList {
                    VStack {
                        HStack(spacing: 8) {
                            SearchBarView(viewModel: viewModel.searchBar)
                                .padding(.vertical)
                            FavoriteButton(isSelected: $viewModel.favoriteFilterButtonIsSelected) { // TODO: extract VM
                                viewModel.tapOnFavoriteFilterButton()
                            }.accessibilityIdentifier("FavoriteFilterButton")
                        }
                        .padding(.horizontal)
                        PaginatedListView(viewModel.list) { rowViewModel in
                            CityRowView(viewModel: rowViewModel)
                        }
                        .safeAreaInset(edge: .bottom) {
                            if viewModel.isShowingEmptyView { // TODO: extract
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title)
                                    VStack {
                                        Text(viewModel.emptyHeadingText).font(.headline)
                                        Text(viewModel.emptySubheadText).font(.subheadline)
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            if viewModel.isShowingMap {
                VStack {
                    if let mapViewModel = viewModel.mapViewModel {
                        CityMapView(viewModel: mapViewModel, hideNavBar: true)
                    }
                    if viewModel.isShowingMapEmptyView {
                        VStack { // TODO: extract
                            Text(viewModel.mapEmptyHeadingText).font(.headline)
                            Text(viewModel.mapEmptySubheadText).font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { viewModel.onAppear() }
    }
}
