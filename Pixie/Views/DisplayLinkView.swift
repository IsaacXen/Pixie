import Cocoa

class LayerHostedView: NSView {
            
    func commonInit() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        setupLayer()
    }
    
    func setupLayer() { }
    
    // MARK: - Init & Deinit
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

}
