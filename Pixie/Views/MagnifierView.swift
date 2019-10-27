import FoundationExtended
import Cocoa

protocol MagnifierViewDelegate: class {
    func magnifierView(_ view: MagnifierView, didUpdateMouseLocation location: NSPoint, flippedLocation: NSPoint)
    func magnifierView(_ view: MagnifierView, colorAtMouseHotSpot color: NSColor)
}

/// ...
///
/// The redraw of the view is driven by a display link object with a `CGScreen` object containing the window of this view. That is, the layers in this view is
/// redraw in every screen frame update.
///
/// By default, when the view is not visible to the user, the view will stop
final class MagnifierView: NSView {
    
    weak var delegate: MagnifierViewDelegate?
    
    @Clamping(1...128) var magnificationFactor: CGFloat = 1 {
        didSet { needsDisplay = true }
    }
    
    var showHotSpot: Bool = true {
        didSet { needsDisplay = true }
    }
    
    var showGrid: Bool = true {
        didSet { needsDisplay = true }
    }
    
    var canShowGrid: Bool {
        magnificationFactor >= 8
    }
    
    var lockX: Bool = false {
        didSet {
            if !lockX { _freezedX = nil }
        }
    }
    
    var lockY: Bool = false {
        didSet {
            if !lockY { _freezedY = nil }
        }
    }
    
    private var _freezedX: CGFloat? = nil
    private var _freezedY: CGFloat? = nil
    
    // MARK: - Layers
    
    private let _imageLayer = CALayer()
    
    private let _gridLayer = CAShapeLayer()
    
    private let _hotSpotContainerLayer = CALayer()
    private let _hotSpotOuterStrokeLayer = CAShapeLayer()
    private let _hotSpotStrokeLayer = CAShapeLayer()
    
    private func _setupLayer() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        layer?.needsDisplayOnBoundsChange = true
        
        layer?.addSublayer(_imageLayer)
        layer?.insertSublayer(_gridLayer, above: _imageLayer)
        layer?.insertSublayer(_hotSpotContainerLayer, above: _gridLayer)
        _hotSpotContainerLayer.addSublayer(_hotSpotOuterStrokeLayer)
        _hotSpotContainerLayer.insertSublayer(_hotSpotStrokeLayer, above: _hotSpotOuterStrokeLayer)
        
        _imageLayer.magnificationFilter = .nearest
        _imageLayer.contentsGravity = .center
        
        _gridLayer.strokeColor = .black
        _gridLayer.lineWidth = 1
        _gridLayer.fillColor = .clear
        
        _hotSpotOuterStrokeLayer.strokeColor = .black
        _hotSpotOuterStrokeLayer.lineWidth = 3
        _hotSpotOuterStrokeLayer.fillColor = .clear
        
        _hotSpotStrokeLayer.strokeColor = .white
        _hotSpotStrokeLayer.lineWidth = 1
        _hotSpotStrokeLayer.fillColor = .clear
    }
    
    override func updateLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _updateImageLayer(in: bounds)
        _updateGridLayer(in: bounds)
        _updateHotSpotLayer(in: bounds)
        CATransaction.commit()
    }
    
    private func _updateImageLayer(in rect: NSRect) {
        let w = ceil((bounds.width / magnificationFactor - 1) / 2) + 1
        let h = ceil((bounds.height / magnificationFactor - 1) / 2) + 1
        
        if let windowID = window?.windowNumber {
            var mouseLocation = NSEvent.mouseLocation
            
            if lockX {
                mouseLocation.x = _freezedX ?? mouseLocation.x
                _freezedX = mouseLocation.x
            }
            
            if lockY {
                mouseLocation.y = _freezedY ?? mouseLocation.y
                _freezedY = mouseLocation.y
            }
            
            let result = ScreenCapture.captureScreenImage(around: mouseLocation, rx: w, ry: h, ecluding: CGWindowID(windowID))

            _imageLayer.contents = result.image
                
            _imageLayer.frame = bounds
                .offsetBy(dx: _zoomedPixelWidthInPoint * result.imageOffsetFactor, dy: -_zoomedPixelWidthInPoint * result.imageOffsetFactor)
                .offsetBy(dx: -_zoomedPixelWidthInPoint * result.subPixelOffset.x, dy: _zoomedPixelWidthInPoint * result.subPixelOffset.y)
            
            _imageLayer.contentsScale = 1 / magnificationFactor * result.imageScaleFactor
            
            delegate?.magnifierView(self, didUpdateMouseLocation: result.mouseLocation, flippedLocation: result.flippedMouseLocation)
            
//            if let image = image {
//                let color = NSBitmapImageRep(cgImage: image).colorAt(x: image.width / 2, y: image.height / 2 - 1)
//                delegate?.magnifierView(self, color: color, atLocation: NSEvent.mouseLocation)
//            }
        }
    }
        
    private func _updateHotSpotLayer(in rect: NSRect) {
        _hotSpotContainerLayer.isHidden = !showHotSpot
        guard showHotSpot else { return }
        
        var alignmentRect = _alignmentRect

        if _alignmentRect.width <= _pixelWidthInPoint {
            alignmentRect = _minAlignmentRect
        }
        
        _hotSpotContainerLayer.frame = alignmentRect.insetBy(dx: -_hotSpotOuterStrokeLayer.lineWidth, dy: -_hotSpotOuterStrokeLayer.lineWidth)
        
        _hotSpotOuterStrokeLayer.frame = _hotSpotContainerLayer.bounds
        _hotSpotOuterStrokeLayer.path = CGPath(rect: _hotSpotOuterStrokeLayer.bounds.insetBy(dx: _hotSpotOuterStrokeLayer.lineWidth / 2, dy: _hotSpotOuterStrokeLayer.lineWidth / 2), transform: nil)
        
        _hotSpotStrokeLayer.frame = _hotSpotContainerLayer.bounds
        _hotSpotStrokeLayer.path = CGPath(rect: _hotSpotStrokeLayer.bounds.insetBy(dx: _hotSpotOuterStrokeLayer.lineWidth / 2, dy: _hotSpotOuterStrokeLayer.lineWidth / 2), transform: nil)
    }
    
    private func _updateGridLayer(in rect: NSRect) {
        _gridLayer.isHidden = !(showGrid && canShowGrid)
        guard showGrid, magnificationFactor >= 8 else { return }
        
        _gridLayer.frame = bounds
        
        var alignmentRect = _alignmentRect
        let path = CGMutablePath()
        
        while !alignmentRect.fullyContains(bounds) {
            path.move(to: NSMakePoint(bounds.minX, alignmentRect.minY))
            path.addLine(to: NSMakePoint(bounds.maxX, alignmentRect.minY))
            path.move(to: NSMakePoint(bounds.minX, alignmentRect.maxY))
            path.addLine(to: NSMakePoint(bounds.maxX, alignmentRect.maxY))
            path.move(to: NSMakePoint(alignmentRect.minX, bounds.minY))
            path.addLine(to: NSMakePoint(alignmentRect.minX, bounds.maxY))
            path.move(to: NSMakePoint(alignmentRect.maxX, bounds.minY))
            path.addLine(to: NSMakePoint(alignmentRect.maxX, bounds.maxY))
            alignmentRect = alignmentRect.insetBy(dx: -_zoomedPixelWidthInPoint, dy: -_zoomedPixelWidthInPoint)
        }
        
        _gridLayer.path = path
    }
    
    // MARK: - Setup Display Link
    
    private var _displayLink: CVDisplayLink!
    
    private func _setupDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink)
        
        CVDisplayLinkSetOutputCallback(_displayLink, { (_, _, _, _, _, ctx) -> CVReturn in
            guard let ctx = ctx else { return kCVReturnError }
            let context = Unmanaged<MagnifierView>.fromOpaque(ctx).takeUnretainedValue()
            DispatchQueue.main.async {
                // TODO: display image layer only
                context.needsDisplay = true
//                context._imageLayer.display()
            }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
    }
    
    // MARK: -
    
    private func _observeForOcclusionStateChanges() {
        NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: window, queue: .main, using: _occlusionStateDidChange)
    }
    
    private func _occlusionStateDidChange(_ notificaiton: Notification) {
        guard let window = notificaiton.object as? NSWindow, self.window == .some(window) else { return }
                
        if window.occlusionState.contains(.visible) {
            CVDisplayLinkStart(_displayLink)
        } else {
            CVDisplayLinkStop(_displayLink)
        }
    }
    
    // MARK: -
    
    func viewDidLoad() {
        _setupLayer()
        _setupDisplayLink()
        _observeForOcclusionStateChanges()
    }
    
    // MARK: - Init & Deinit
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewDidLoad()
    }
    
}

extension MagnifierView {
    
    private var _mouseLocation: NSPoint {
        NSEvent.mouseLocation
    }
    
    private var _screen: NSScreen {
        NSScreen.hovered ?? NSScreen.main!
    }
    
    private var _pixelWidthInPoint: CGFloat {
        1 / _screen.backingScaleFactor
    }
    
    private var _zoomedPixelWidthInPoint: CGFloat {
        _pixelWidthInPoint * magnificationFactor
    }
    
    private var _alignmentRect: NSRect {
        NSMakeRect(bounds.midX - _zoomedPixelWidthInPoint / 2, bounds.midY - _zoomedPixelWidthInPoint / 2, _zoomedPixelWidthInPoint, _zoomedPixelWidthInPoint)
    }
    
    private var _minAlignmentRect: NSRect {
        NSMakeRect(bounds.midX - _pixelWidthInPoint / 2, bounds.midY - _pixelWidthInPoint / 2, _pixelWidthInPoint, _pixelWidthInPoint)
    }
    
}
