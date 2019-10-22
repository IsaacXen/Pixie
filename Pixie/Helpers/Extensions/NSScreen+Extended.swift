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
    
}
