import Cocoa

class HudView: LayerHostedView {
    
    var magnificationFactor: CGFloat = 12 {
        didSet { needsDisplay = true }
    }
    
    var showGrid: Bool = true {
        didSet { needsDisplay = true }
    }
    
    var showHotSpot: Bool = true {
        didSet { needsDisplay = true }
    }
    
    var canShowGrid: Bool {
        return centerBoxRect(in: bounds).width >= 4
    }
    
    private var _gridLayer = CAShapeLayer()
    
    private var _hotSpotLayer = CAShapeLayer()
    private var _hotSpotInnerStrokeLayer = CAShapeLayer()
    private var _hotSpotOuterStrokeLayer = CAShapeLayer()
    
    override func setupLayer() {
        layer?.addSublayer(_gridLayer)
        layer?.addSublayer(_hotSpotLayer)
        
        _hotSpotLayer.addSublayer(_hotSpotOuterStrokeLayer)
        _hotSpotLayer.insertSublayer(_hotSpotInnerStrokeLayer, above: _hotSpotOuterStrokeLayer)
        
        layer?.needsDisplayOnBoundsChange = true
        
        _gridLayer.fillColor = NSColor.clear.cgColor
        _gridLayer.lineWidth = 1
        
        _hotSpotLayer.fillColor = .clear
        _hotSpotLayer.strokeColor = .clear
        
        _hotSpotOuterStrokeLayer.strokeColor = .black
        _hotSpotOuterStrokeLayer.lineWidth = 3
        _hotSpotOuterStrokeLayer.fillColor = .clear
        
        _hotSpotInnerStrokeLayer.strokeColor = .white
        _hotSpotInnerStrokeLayer.lineWidth = 1
        _hotSpotInnerStrokeLayer.fillColor = .clear
    }
    
    override func updateLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let boxRect = centerBoxRect(in: bounds)

        updateGrid(with: boxRect)
        updateHotSpot(in: boxRect)
        
        CATransaction.commit()
    }
    
    func updateGrid(with boxRect: NSRect) {
        guard showGrid, canShowGrid else {
            _gridLayer.isHidden = true
            return
        }
            
        _gridLayer.isHidden = false
        
        _gridLayer.frame = bounds
        let path = CGMutablePath()

        var rect = boxRect

        while !rect.fullyContains(bounds) {
            path.move(to: NSMakePoint(rect.minX, bounds.minY))
            path.addLine(to: NSMakePoint(rect.minX, bounds.maxY))

            path.move(to: NSMakePoint(rect.maxX, bounds.minY))
            path.addLine(to: NSMakePoint(rect.maxX, bounds.maxY))

            path.move(to: NSMakePoint(bounds.minX, rect.minY))
            path.addLine(to: NSMakePoint(bounds.maxX, rect.minY))

            path.move(to: NSMakePoint(bounds.minX, rect.maxY))
            path.addLine(to: NSMakePoint(bounds.maxX, rect.maxY))

            rect = rect.insetBy(dx: -boxRect.width, dy: -boxRect.width)
        }

        _gridLayer.path = path
        _gridLayer.strokeColor = NSColor.black.cgColor
    }
    
    func updateHotSpot(in rect: NSRect) {
        guard showHotSpot else {
            _hotSpotLayer.isHidden = true
            return
        }
        
        _hotSpotLayer.isHidden = false
        
        _hotSpotLayer.frame = rect.insetBy(dx: -2.5, dy: -2.5)
        
        // TODO: keep hotspot rect size to show at lease one pixel
//        if _hotSpotLayer.frame.width - _hotSpotOuterStrokeLayer.lineWidth * 2 < 1 / (NSScreen.key?.backingScaleFactor ?? 1) {
//            _hotSpotLayer.frame = rect.insetBy(dx: <#T##CGFloat#>, dy: <#T##CGFloat#>)
//        }
        
        _hotSpotOuterStrokeLayer.frame = _hotSpotLayer.bounds
        _hotSpotOuterStrokeLayer.path = CGPath(rect: _hotSpotOuterStrokeLayer.bounds.insetBy(dx: _hotSpotOuterStrokeLayer.lineWidth / 2, dy: _hotSpotOuterStrokeLayer.lineWidth / 2), transform: nil)
        
        _hotSpotInnerStrokeLayer.frame = _hotSpotLayer.bounds
        _hotSpotInnerStrokeLayer.path = CGPath(rect: _hotSpotInnerStrokeLayer.bounds.insetBy(dx: _hotSpotOuterStrokeLayer.lineWidth / 2, dy: _hotSpotOuterStrokeLayer.lineWidth / 2), transform: nil)
        
    }
    
    func centerBoxRect(in bounds: NSRect) -> NSRect {
        let backingScaleFactor = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })?.backingScaleFactor ?? 1
        let boxWidth = magnificationFactor / backingScaleFactor
        let midPoint = NSMakePoint(bounds.midX, bounds.midY)
        return NSRect(origin: midPoint, size: .zero).insetBy(dx: -boxWidth / 2, dy: -boxWidth / 2)
    }
    
}

extension CGRect {
    func fullyContains(_ otherRect: CGRect) -> Bool {
        return minX <= otherRect.minX && maxX >= otherRect.maxX && minY <= otherRect.minY && maxY >= otherRect.maxY
    }
}

extension NSScreen {
    
    static var key: NSScreen? {
        return screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
    }
    
}
