//
//  PaginatedListViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

class PaginatedListViewModel<T>: ObservableObject {
    @Published var visibleItems: [T]
    
    var items: [T] {
        didSet {
            visibleItems = Array(items[0..<min(pageSize, items.count)])
        }
    }
    private let pageSize: Int
    private let prefetchOffset: Int
    
    init(items: [T], pageSize: Int, prefetchOffset: Int) {
        self.items = items
        self.pageSize = pageSize
        self.prefetchOffset = prefetchOffset
        visibleItems = Array(items[0..<min(pageSize, items.count)])
    }
    
    func onDidDisplayItemAtIndex(_ index: Int) {
        if visibleItems.count - index <= prefetchOffset {
            visibleItems += items[visibleItems.count..<min(visibleItems.count + pageSize, items.count)]
        }
    }
}
