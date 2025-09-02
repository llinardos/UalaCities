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
                    PaginatedListView(viewModel.list) { row in
                        Text(row.headingText)
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
                    .searchable(
                        text: $viewModel.searchBarText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: viewModel.searchBarPlaceholder
                    )
                }
            }
            .onAppear { viewModel.onAppear() }
        }
    }
}

#Preview("ok") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 200, data: try! JSONEncoder().encode([City(_id: 1, name: "City 1", country: "AA")]))]), runner: GlobalRunner()))
}

#Preview("error") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 500)]), runner: GlobalRunner()))
}
