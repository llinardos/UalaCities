import Foundation

extension Array {
    func unique() -> Element? {
        guard count == 1 else { return nil }
        return first
    }
}
