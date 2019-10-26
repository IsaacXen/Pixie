import AppKit

extension NSScreen {
    
    @available(OSX, unavailable, renamed: "hovered")
    static var key: NSScreen? {
        return screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
    }
    
    /// Returns the screen object containning the mouse cursor.
    ///
    /// The hovered screen is not necessaily the same screen that contains the menu bar or has its origin at
    /// `(0, 0)`. The hovered screen refers to the screen containing the mouse cursor, specifily, the screen which its frame contains the curren mouse position.
    class var hovered: NSScreen? {
        return screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
    }
    
    /// Convert a point from a screen coordinate to the receiver's coordinate.
    /// - Parameter point: The `NSPoint` value to convert from. This function assume `point` is in `screen` coordinate system with bottom-left origin.
    /// - Parameter screen: The screen object of which the `point` is coordinated.
    /// - Parameter flipped: Specific whether the result point has a flipped coordinate. `true` means the result should has a coordinate origin top-left. `false` for bottom-left.
    func convert(_ point: NSPoint, from screen: NSScreen?, flipped: Bool = false) -> NSPoint {
        guard let fromScreen = screen ?? NSScreen.screens.first else { return point }
        
        var x, y: CGFloat
        
        if flipped {
            x = point.x + fromScreen.frame.minX - frame.minX
            y = frame.maxY - point.y + fromScreen.frame.minY
        } else {
            x = point.x + fromScreen.frame.minX - frame.minX
            y = point.y + fromScreen.frame.minY - frame.minY
        }
        
        return NSMakePoint(x, y)
    }
    
}
