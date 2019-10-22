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

    // FIXME: Change this to CGImage(windowListFromArrayScreenBounds:windowArray:imageOption:).
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
        
        let image = CGWindowListCreateImage(captureRectInPt, .optionOnScreenBelowWindow, windowId, [])
        
        return (
            screen.backingScaleFactor,
            NSMakePoint(dx, dy),
            image
        )
    }
    
    
    static func captureScreen(centerOf origin: CGPoint, dw: CGFloat, dh: CGFloat) -> (CGFloat, CGPoint, CGImage?) {
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
        
        let image = CGWindowListCreateImage(captureRectInPt, [.optionOnScreenOnly], kCGNullWindowID, [])
                
        return (
            screen.backingScaleFactor,
            NSMakePoint(dx, dy),
            image
        )
    }
    
    static func windowArray(excluding: CGWindowID) -> CFArray {
        let list = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [[String: Any]]

        let mapped = list.compactMap {
            $0[kCGWindowNumber as String] as? CGWindowID
        }
        
        let filtered = mapped.filter {
            $0 != excluding
        }
        
//        print(list.count, mapped.count, filtered.count, excluding, CFArrayGetCount(filtered as CFArray))
        
        return filtered as CFArray
    }
    
}
