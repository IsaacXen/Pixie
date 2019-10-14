import Cocoa

class MagnifierView: DisplayLinkView {
    
    var magnificationFactor: CGFloat = 16
    
    private let _screenLayer = CALayer()
    private let _hotSpotLayer = CAShapeLayer()
    
    private var _needDisplayHotSpotLayer: Bool = false
    
    override func setupLayer() {
        layer?.addSublayer(_screenLayer)
        layer?.addSublayer(_hotSpotLayer)
        
        _screenLayer.contentsGravity = .center
        _screenLayer.magnificationFilter = .nearest
        _screenLayer.contentsScale = (NSScreen.main?.backingScaleFactor ?? 1) / magnificationFactor
        
    }
    
    override func updateLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        _screenLayer.frame = bounds
        
         let size = NSMakeSize(ceil(bounds.width / magnificationFactor), ceil(bounds.height / magnificationFactor))
        _screenLayer.contents = ScreenCapture.captureScreen(at: NSEvent.mouseLocation, size: size)
        
        CATransaction.commit()
    }
    
}

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

    static func captureScreen(at origin: NSPoint, size: NSSize) -> CGImage? {
        guard let screen = NSScreen.main else {
            return nil
        }
        
        let origin = NSMakePoint(origin.x, screen.frame.height - origin.y)
        let dX = size.width / 2
        let dY = size.height / 2
        
        let rect = NSRect(origin: origin, size: .zero).insetBy(dx: -dX, dy: -dY)
        
        return CGWindowListCreateImage(rect, [.optionOnScreenOnly], kCGNullWindowID, [])
    }
    
}
