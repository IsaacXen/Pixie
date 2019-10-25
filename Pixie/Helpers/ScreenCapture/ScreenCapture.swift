import FoundationExtended
import AppKit

class ScreenCapture: NSObject {

    enum AuthorizationStatus {
        case authorized, denied
    }
    
    /// Returns the authorization status on Screen Recording.
    ///
    /// This check *Screen Recording* authorization status by calling `CGWindowListCopyWindowInfo(::)` function and check if the returned result contains
    /// sensitive infomation likes window title, which is filtered if caller did not have the authorization. Calling this will not triger an authorization
    /// prompt.
    static var authorizationStatus: AuthorizationStatus {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: AnyObject]]
        
        let window = windows.filter {
            kCGMainMenuWindowLevel != $0[kCGWindowLayer as String] as! CGWindowLevel && $0[kCGWindowName as String] != nil
        }
        
        return window.count > 0 ? .authorized : .denied
    }
    
    /// Present an authorization prompt if possible.
    ///
    /// This function simply call `CGWindowListCreateImage(:::)` to trigger a prompt presentation. The prompt is only presented on the first time. Once the
    /// prompt is presented, calling this function does nothing.
    ///
    /// It's your responsibility to present a helpful message to notify user to take action on the prompt, and guide user to *Screen Recording* section under
    /// *System Preference* -> *Security & Privacy* -> *Privacy* and allow your app to record the contents of the screen.
    static func promptIfPossible() {
        CGWindowListCreateImage(.infinite, .optionOnScreenOnly, kCGNullWindowID, [])
    }
    
    static func captureScreenImage(around location: NSPoint, rx: CGFloat, ry: CGFloat, ecluding windowID: CGWindowID) -> Result {
        guard
            let primaryScreen = NSScreen.screens.first,
            let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]]
            else { return Result(image: nil, mouseLocation: .zero, flippedMouseLocation: .zero) }
        
        let mouseLocationPtInPrimaryTopLeft = NSMakePoint(location.x, primaryScreen.frame.maxY - location.y)
        let captureRect = NSMakeRect(floor(mouseLocationPtInPrimaryTopLeft.x), floor(mouseLocationPtInPrimaryTopLeft.y), 1, 1).insetBy(dx: -rx, dy: -ry)
                         
        let sortedIDs: [CGWindowID] = info.sorted {
            $0[kCGWindowLayer as String] as? CGWindowLevel ?? 0 > $1[kCGWindowLayer as String] as? CGWindowLevel ?? 0
        }.compactMap {
            $0[kCGWindowNumber as String] as? CGWindowID
        }.filter {
            $0 != windowID
        }
        
        let idsPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: sortedIDs.count)
        for (index, id) in sortedIDs.enumerated() {
            idsPointer[index] = UnsafeRawPointer(bitPattern: UInt(id))
        }
        
        let windows = CFArrayCreate(nil, idsPointer, sortedIDs.count, nil) ?? [] as CFArray
        
        if let image = CGImage(windowListFromArrayScreenBounds: captureRect, windowArray: windows, imageOption: []) {
            let imageScale = CGFloat(image.width) / captureRect.width
            return Result(image: image, mouseLocation: location, flippedMouseLocation: mouseLocationPtInPrimaryTopLeft, imageScaleFactor: imageScale)
        }
        
        return Result(image: nil, mouseLocation: location, flippedMouseLocation: mouseLocationPtInPrimaryTopLeft)
    }

    struct Result {
        
        var image: CGImage?
        
        var mouseLocation: NSPoint
        
        /// Mouse location of this image center.
        ///
        /// The coordinates of the point must be specified in screen coordinates, where the screen origin is in the upper-left corner of the main display and y-axis values increase downward. Specify null to indicate the minimum rectangle that encloses the specified windows. Specify infinite to capture the entire desktop area.
        var flippedMouseLocation: NSPoint
        
    //    var centerPixelRect: NSRect
    //
    //    var centerPixelColor: NSColor

        //        let xPx = floor(mouseLocationPtInPrimaryTopLeft.x, to: 1 / hoveredScreen.backingScaleFactor)
        //        let yPx = floor(mouseLocationPtInPrimaryTopLeft.y, to: 1 / hoveredScreen.backingScaleFactor)
                    
        var backingScaleFactor: CGFloat {
            let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, true) })
            return screen?.backingScaleFactor ?? 1
        }
        
        var imageScaleFactor: CGFloat = 1
        
        var screenFrame: NSRect {
            let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, true) })
            return screen?.frame ?? .zero
        }
        
        var subPixelOffset: CGPoint {
            var x = floor(flippedMouseLocation.x, to: 1 / backingScaleFactor).truncatingRemainder(dividingBy: 1)
            var y = floor(flippedMouseLocation.y, to: 1 / backingScaleFactor).truncatingRemainder(dividingBy: 1)
            
            x = x * backingScaleFactor
            y = y * backingScaleFactor
            
            return NSMakePoint(x, y)
        }
        
        var imageOffsetFactor: CGFloat {
            if backingScaleFactor <= 1 {
                return 0
            } else {
                return 1 / backingScaleFactor
            }
        }
    }

}
