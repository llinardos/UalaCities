//
//  PaginatedListViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI

struct PaginatedListView<T, RowT: Identifiable, RowContent: View>: View {
    @ObservedObject private var viewModel: PaginatedListViewModel<T, RowT>
    private let rowContent: (RowT) -> RowContent
    
    init(_ viewModel: PaginatedListViewModel<T, RowT>, rowContent: @escaping (RowT) -> RowContent) {
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
