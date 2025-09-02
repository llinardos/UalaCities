import Foundation

extension Array {
    func unique() -> Element? {
        guard count == 1 else { return nil }
        return first
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
