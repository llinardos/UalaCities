import XCTest
@testable import UalaCities

class PaginatedListTests: XCTestCase {
    func testPaginatedList() {
        let list = PaginatedListViewModel(items: Array(1...25), pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        list.onDidDisplayItemAtIndex(4)
        list.onDidDisplayItemAtIndex(5)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        list.onDidDisplayItemAtIndex(12)
        XCTAssertEqual(Array(1...20), list.visibleItems)
        list.onDidDisplayItemAtIndex(18)
        XCTAssertEqual(Array(1...25), list.visibleItems)
        
        // change items
        list.items = Array(1...12)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(6)
        XCTAssertEqual(Array(1...10), list.visibleItems)
        list.onDidDisplayItemAtIndex(7)
        XCTAssertEqual(Array(1...12), list.visibleItems)
    }
    
    func testPaginatedListEmpty() {
        let list = PaginatedListViewModel(items: [Int](), pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual([], list.visibleItems)
    }
    
    func testPaginatedPageSizeBiggerThanItemsCount() {
        let list = PaginatedListViewModel(items: [1,2,3], pageSize: 10, prefetchOffset: 3)
        XCTAssertEqual([1,2,3], list.visibleItems)
        list.onDidDisplayItemAtIndex(1)
        list.onDidDisplayItemAtIndex(2)
        list.onDidDisplayItemAtIndex(3)
        XCTAssertEqual([1,2,3], list.visibleItems)
    }
}
