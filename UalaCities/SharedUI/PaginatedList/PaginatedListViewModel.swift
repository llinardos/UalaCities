//
//  PaginatedListViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class PaginatedListViewModel<T, RowT>: ObservableObject {
    @Published var visibleItems: [RowT] = []
    
    var items: [T] {
        didSet {
            visibleItems = Array(items[0..<min(pageSize, items.count)]).map { makeRow($0) }
        }
    }
    private let pageSize: Int
    private let prefetchOffset: Int
    private let makeRow: (T) -> RowT
    
    init(items: [T], pageSize: Int, prefetchOffset: Int, makeRow: @escaping (T) -> RowT) {
        self.items = items
        self.pageSize = pageSize
        self.prefetchOffset = prefetchOffset
        self.makeRow = makeRow
        visibleItems = Array(items[0..<min(pageSize, items.count)]).map { makeRow($0) }
    }
    
    func onDidDisplayItemAtIndex(_ index: Int) {
        if visibleItems.count - index <= prefetchOffset {
            visibleItems += items[visibleItems.count..<min(visibleItems.count + pageSize, items.count)].map { makeRow($0) }
        }
    }
}
