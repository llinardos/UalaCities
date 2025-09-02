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
                                .padding(.vertical)
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

extension CitiesScreenView {
    static var ok: CitiesScreenView {
        let http = StubbedHTTPClient([.init(statusCode: 200, data: try? JSONEncoder().encode(TestData.Cities.filterExample))])
        let api = CitiesAPI(httpClient: http)
        let store = CitiesStore(citiesAPI: api, runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults())
        let vm = CitiesScreenViewModel(citiesStore: store)
        return CitiesScreenView(viewModel: vm)
    }
    static var error: CitiesScreenView {
        let http = StubbedHTTPClient([.init(statusCode: 500)])
        let api = CitiesAPI(httpClient: http)
        let store = CitiesStore(citiesAPI: api, runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults())
        let vm = CitiesScreenViewModel(citiesStore: store)
        return CitiesScreenView(viewModel: vm)
    }
    static var loading: CitiesScreenView {
        let http = ControlledHTTPClient()
        let api = CitiesAPI(httpClient: http)
        let store = CitiesStore(citiesAPI: api, runner: GlobalRunner(), userDefaults: InRamAppleUserDefaults())
        let vm = CitiesScreenViewModel(citiesStore: store)
        return CitiesScreenView(viewModel: vm)
    }
    static var favs: CitiesScreenView {
        let http = StubbedHTTPClient([.init(statusCode: 200, data: try? JSONEncoder().encode(TestData.Cities.filterExample))])
        let api = CitiesAPI(httpClient: http)
        let userDefaults = InRamAppleUserDefaults()
        userDefaults.set([TestData.Cities.sidney._id], forKey: "favoritesCityIds")
        let store = CitiesStore(citiesAPI: api, runner: GlobalRunner(), userDefaults: userDefaults)
        let vm = CitiesScreenViewModel(citiesStore: store)
        vm.citiesListItems.first?.onFavoriteTap?()
        return CitiesScreenView(viewModel: vm)
    }
}

#Preview("ok") { CitiesScreenView.ok }
#Preview("error") { CitiesScreenView.error }
#Preview("loading") { CitiesScreenView.loading }
#Preview("favs") { CitiesScreenView.favs }
