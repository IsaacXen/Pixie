import Cocoa

class MagnifierView: LayerHostedView, DisplayLinkSubscriber {
    
    var magnificationFactor: CGFloat = 32
    
    private let _screenLayer = CALayer()
    
    override func setupLayer() {
        layer?.addSublayer(_screenLayer)
        
        _screenLayer.contentsGravity = .center
        _screenLayer.magnificationFilter = .nearest
    }
    
    override func updateLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let mouseLocation = NSEvent.mouseLocation
        
        let w = ceil((bounds.width / magnificationFactor - 1) / 2) + 1
        let h = ceil((bounds.height / magnificationFactor - 1) / 2) + 1
        
        let (scale, offset, image): (CGFloat, CGPoint, CGImage?)
        
        if let windowID = window?.windowNumber {
            (scale, offset, image) = ScreenCapture.captureScreen(centerOf: mouseLocation, dw: w, dh: h, excluding: CGWindowID(windowID))
        } else {
            (scale, offset, image) = ScreenCapture.captureScreen(centerOf: mouseLocation, dw: w, dh: h)
        }
        
        _screenLayer.contents = image
        _screenLayer.frame = bounds
            .offsetBy(dx: -offset.x * magnificationFactor / 2, dy: offset.y * -magnificationFactor / 2)
            .offsetBy(dx: magnificationFactor / 4, dy: -magnificationFactor / 4)

        _screenLayer.contentsScale = 1 / magnificationFactor * scale
        
        CATransaction.commit()
    }
    
    func displayLink(_ displayLink: DisplayLink, willOutputFrameInTime outputTime: CVTimeStamp, currentTime: CVTimeStamp) {
        needsDisplay = true
    }
    
}
