//
//  PaginatedListViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI

struct PaginatedListView<T: Identifiable, RowContent: View>: View {
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
        .listStyle(.plain)
    }
}
