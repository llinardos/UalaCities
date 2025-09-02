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
        NavigationStack {
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
                    VStack {
                        HStack(spacing: 8) {
                            SearchBarView(viewModel: viewModel.searchBar)
                            Button {
                                viewModel.onTapFavoriteFilterButton()
                            } label: {
                                Image(systemName: viewModel.favoriteFilterButtonIsSelected ? "star.fill" : "star")
                                    .foregroundColor(viewModel.favoriteFilterButtonIsSelected ? .yellow : .primary)
                                    .font(.body)
                            }
                            .accessibilityIdentifier("FavoriteFilterButton")
                            .accessibilityAddTraits(viewModel.favoriteFilterButtonIsSelected ? .isSelected : [])
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        PaginatedListView(viewModel.list) { rowViewModel in
                            CityRowView(viewModel: rowViewModel)
//                            HStack {
//                                Text(row.headingText)
//                                Spacer()
//                                Button {
//                                    row.onFavoriteButtonTap()
//                                } label: {
//                                    Image(systemName: row.favoriteButtonIsSelected ? "star.fill" : "star")
//                                        .foregroundColor(row.favoriteButtonIsSelected ? .yellow : .primary)
//                                        .font(.body)
//                                }
//                                .accessibilityAddTraits(row.favoriteButtonIsSelected ? .isSelected : [])
//                                .accessibilityIdentifier("FavoriteButton")
//                                .buttonStyle(.plain)
//                            }
                        }
                        .safeAreaInset(edge: .bottom) {
                            if viewModel.isShowingEmptyView {
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
            .onAppear { viewModel.onAppear() }
        }
    }
}

#Preview("ok") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 200, data: try! JSONEncoder().encode([CityDTO(_id: 1, name: "City 1", country: "AA")]))]), runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults()))
}

#Preview("error") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 500)]), runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults()))
}
