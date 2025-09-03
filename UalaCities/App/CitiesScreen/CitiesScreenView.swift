//
//  ContentView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import SwiftUI

struct InfoMessageView: View {
    @ObservedObject var viewModel: InfoMessageViewModel
    
    var body: some View {
        if viewModel.isShowing {
            VStack(spacing: 16) {
                if let imageName = viewModel.iconSystemName {
                    Image(systemName: imageName)
                        .font(.title)
                }
                VStack {
                    Text(viewModel.headingText).font(.headline)
                    Text(viewModel.subheadText).font(.subheadline)
                }
            }
            .onTapGesture { viewModel.tap() }
        }
    }
}

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
                            FavoriteButton(isSelected: $viewModel.favoriteFilterButtonIsSelected) { // TODO: extract VM
                                viewModel.tapOnFavoriteFilterButton()
                            }.accessibilityIdentifier("FavoriteFilterButton")
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
