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
                    PaginatedList(viewModel.list) { row in
                        Text(row.headingText)
                    }
                    .searchable(text: $viewModel.searchBarText, placement: .automatic, prompt: viewModel.searchBarPlaceholder)
                }
            }
            .onAppear { viewModel.onAppear() }
        }
    }
}

struct PaginatedList<T: Identifiable, RowContent: View>: View {
    @ObservedObject private var viewModel: PaginatedListViewModel<T>
    private let rowContent: (T) -> RowContent
    
    init(_ viewModel: PaginatedListViewModel<T>, rowContent: @escaping (T) -> RowContent) {
        self.viewModel = viewModel
        self.rowContent = rowContent
    }
    
    var body: some View {
        List(Array(viewModel.visibleItems.enumerated()), id: \.element.id) { (index, item) in
            rowContent(item)
                .onAppear {
                    viewModel.onDidDisplayItemAtIndex(index)
                }
        }
    }
}


#Preview("ok") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 200, data: try! JSONEncoder().encode([City(name: "City 1", country: "AA")]))])))
}

#Preview("error") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 500)])))
}
