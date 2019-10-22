import AppKit

class ScreenCapture: NSObject {

    enum AuthorizationStatus {
        case authorized, denied
    }
    
    static var authorizationStatus: AuthorizationStatus {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: AnyObject]]
        
        let window = windows.filter {
            kCGMainMenuWindowLevel != $0[kCGWindowLayer as String] as! CGWindowLevel && $0[kCGWindowName as String] != nil
        }
        
        return window.count > 0 ? .authorized : .denied
    }
    
    /// Present an authorization prompt if possible.
    ///
    /// This function simply call `CGWindowListCreateImage(:::)` to trigger a prompt presentation. The prompt is only presented on the first time. Once the prompt is presented, calling this function does nothing.
    ///
    /// It's your responsibility to present a helpful message to notify user to take action on the prompt, and guide user to *Screen Recording* section under *System Preference* -> *Security & Privacy* -> *Privacy* and allow your app to record the contents of the screen.
    static func promptIfPossible() {
        CGWindowListCreateImage(.infinite, .optionOnScreenOnly, kCGNullWindowID, [])
    }

    static func captureScreen(centerOf origin: CGPoint, dw: CGFloat, dh: CGFloat, excluding windowId: CGWindowID) -> (CGFloat, CGPoint, CGImage?) {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(origin, $0.frame, false) }) else {
            return (0, .zero, nil)
        }
        
        let fLocXInPt = floor(origin.x)
        var fLocYInPt = floor(origin.y)
        let fLocXInPx = floor(origin.x * screen.backingScaleFactor)
        let fLocYInPx = floor(origin.y * screen.backingScaleFactor)
        
        fLocYInPt = screen.frame.height - fLocYInPt - screen.frame.minY
        
        let dx = fLocXInPx.truncatingRemainder(dividingBy: screen.backingScaleFactor)
        var dy = fLocYInPx.truncatingRemainder(dividingBy: screen.backingScaleFactor)
        
        dy = fLocYInPx < 1 ? 1 : dy
        
        let dwInPt = dw
        let dhInPt = dh
        
        let centerRectInPt = NSMakeRect(fLocXInPt, fLocYInPt, 1, 1)
        let captureRectInPt = centerRectInPt.insetBy(dx: -dwInPt, dy: -dhInPt)
        
        let windows = windowArray(excluding: windowId)
        let image = CGImage(windowListFromArrayScreenBounds: captureRectInPt, windowArray: windows, imageOption: [])
        
        return (
            screen.backingScaleFactor,
            NSMakePoint(dx, dy),
            image
        )
    }

    static func windowArray(excluding: CGWindowID) -> CFArray {
        guard let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return [] as CFArray }
        
        let sortedIDs: [CGWindowID] = info.sorted {
            $0[kCGWindowLayer as String] as? CGWindowLevel ?? 0 > $1[kCGWindowLayer as String] as? CGWindowLevel ?? 0
        }.compactMap {
            let id = $0[kCGWindowNumber as String] as? CGWindowID
            return id == excluding ?  nil : id
        }
        
        let idsPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: sortedIDs.count)
        for (index, id) in sortedIDs.enumerated() {
            idsPointer[index] = UnsafeRawPointer(bitPattern: UInt(id))
        }
        
        return CFArrayCreate(nil, idsPointer, sortedIDs.count, nil) ?? [] as CFArray
    }
    
}
