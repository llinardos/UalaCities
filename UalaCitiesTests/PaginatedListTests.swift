import XCTest
@testable import UalaCities

class PaginatedListTests: XCTestCase {
    func testPaginatedList() {
        var makeRowCount = 0
        let list = PaginatedListViewModel(items: Array(1...25), pageSize: 10, prefetchOffset: 3, makeRow: { makeRowCount += 1; return $0 })
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        list.onDidDisplayItemAtIndex(4)
        list.onDidDisplayItemAtIndex(5)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        XCTAssertEqual(10, makeRowCount)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        XCTAssertEqual(20, makeRowCount)
        list.onDidDisplayItemAtIndex(12)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        list.onDidDisplayItemAtIndex(18)
        XCTAssertEqual(Array(1...25), list.visibleItems)
        XCTAssertEqual(25, makeRowCount)
        
        // change items
        list.items = Array(1...12)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...12), list.visibleItems)
    }
    
    func testPaginatedListEmpty() {
        let list = PaginatedListViewModel(items: [Int](), pageSize: 10, prefetchOffset: 3, makeRow: { $0 })
        XCTAssertEqual([], list.visibleItems)
    }
    
    func testPaginatedPageSizeBiggerThanItemsCount() {
        let list = PaginatedListViewModel(items: [1,2,3], pageSize: 10, prefetchOffset: 3, makeRow: { $0 })
        XCTAssertEqual([1,2,3], list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        XCTAssertEqual([1,2,3], list.visibleItems)
    }
}
