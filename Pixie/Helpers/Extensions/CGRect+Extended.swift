import AppKit

extension CGRect {
    
    /// Returns whether the given rect is a subrect of the receiver.
    ///
    /// This result of this function is a equalievent to the result by checking whether the intersection of the receiver rect and the given rect is equal to
    /// the given rect.
    ///
    /// - Parameters:
    ///   - otherRect: The frame rect to examine.
    ///
    /// - Returns: `true` if the given rect is a subset of the receiver, `false` otherwise.
    func fullyContains(_ otherRect: CGRect) -> Bool {
        return minX <= otherRect.minX && maxX >= otherRect.maxX && minY <= otherRect.minY && maxY >= otherRect.maxY
    }
    
}
