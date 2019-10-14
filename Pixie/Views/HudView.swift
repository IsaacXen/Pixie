import Cocoa

class HudView: LayerHostedView {
    
    var magnificationFactor: CGFloat = 12 {
        didSet { needsDisplay = true }
    }
    
    var showGrid: Bool = true
    var showHotSpot: Bool = true
    
    private var _gridLayer = CAShapeLayer()
    private var _hotSpotLayer = CAShapeLayer()
    
    override func setupLayer() {
        layer?.addSublayer(_gridLayer)
        layer?.addSublayer(_hotSpotLayer)
        
        layer?.needsDisplayOnBoundsChange = true
        
        _gridLayer.fillColor = NSColor.clear.cgColor
        _gridLayer.lineWidth = 1
        
        _hotSpotLayer.borderWidth = 1
        _hotSpotLayer.lineWidth = 1
        _hotSpotLayer.fillColor = .clear
    }
    
    override func updateLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let backingScaleFactor = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })?.backingScaleFactor ?? 1
        
        let boxWidth = magnificationFactor / backingScaleFactor
        
        let midPoint = NSMakePoint(bounds.midX, bounds.midY)
        let hotSpotRect = NSRect(origin: midPoint, size: .zero).insetBy(dx: -boxWidth / 2, dy: -boxWidth / 2)
        
        _gridLayer.isHidden = !showGrid
        
        if showGrid {
            _gridLayer.frame = bounds
            let path = CGMutablePath()
            
            var rect = hotSpotRect
            
            while !rect.fullyContains(bounds) {
                path.move(to: NSMakePoint(rect.minX, bounds.minY))
                path.addLine(to: NSMakePoint(rect.minX, bounds.maxY))

                path.move(to: NSMakePoint(rect.maxX, bounds.minY))
                path.addLine(to: NSMakePoint(rect.maxX, bounds.maxY))
                
                path.move(to: NSMakePoint(bounds.minX, rect.minY))
                path.addLine(to: NSMakePoint(bounds.maxX, rect.minY))
                
                path.move(to: NSMakePoint(bounds.minX, rect.maxY))
                path.addLine(to: NSMakePoint(bounds.maxX, rect.maxY))
                
                rect = rect.insetBy(dx: -boxWidth, dy: -boxWidth)
            }
            
            _gridLayer.path = path
            _gridLayer.strokeColor = NSColor.black.cgColor
            
            _hotSpotLayer.isHidden = !showHotSpot
            
            if showHotSpot {
                _hotSpotLayer.frame = hotSpotRect.insetBy(dx: -2.5, dy: -2.5)
                _hotSpotLayer.borderColor = .black
                _hotSpotLayer.path = CGPath(rect: _hotSpotLayer.bounds.insetBy(dx: 1.5, dy: 1.5), transform: nil)
                _hotSpotLayer.strokeColor = .white
            }
        }
        
        CATransaction.commit()
    }
    
}

extension CGRect {
    
    func fullyContains(_ otherRect: CGRect) -> Bool {
        return minX <= otherRect.minX && maxX >= otherRect.maxX && minY <= otherRect.minY && maxY >= otherRect.maxY
    }
    
}
