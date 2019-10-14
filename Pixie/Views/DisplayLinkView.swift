import Cocoa

class DisplayLinkView: NSView {
    
    private var displayLink: CVDisplayLink!
        
    func commonInit() {
        // setup layers
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        setupLayer()
        
        // setup display link
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        
        CVDisplayLinkSetOutputCallback(displayLink, { (_, _, _, _, _, context) -> CVReturn in
            guard let context = context else { return kCVReturnError }
            let view = Unmanaged<NSView>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async { view.needsDisplay = true }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

    }
    
    func setupLayer() { }
    
    // MARK: -
    
    func resumeLinking() {
        CVDisplayLinkStart(displayLink)
    }
    
    func stopLinking() {
        CVDisplayLinkStop(displayLink)
    }
    
    // MARK: - Init & Deinit
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        stopLinking()
    }

}
