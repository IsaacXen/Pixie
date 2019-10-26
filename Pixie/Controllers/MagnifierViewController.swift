import FoundationExtended
import Cocoa

class MagnifierViewController: NSViewController, DefaultsControllerSubscriber {

    var showMouseCoordinate: Bool = false {
        didSet {
            _bottomLeftLabel.isHidden = !showMouseCoordinate
        }
    }
    
    var mouseCoordinateInPixel: Bool = false
    
    var screensHasSeparateCooridinate: Bool = false
    
    var isMouseCoordinateFlipped: Bool = true
    
    // MARK: Subviews
        
    lazy var magnifierView: MagnifierView = {
        let view = MagnifierView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let _bottomLeftLabel: RoundedTooltipsLabel = {
        let view = RoundedTooltipsLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let _bottomRightLabel: RoundedTooltipsLabel = {
        let view = RoundedTooltipsLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Setup Subviews
    
    func setupSubviews(in view: NSView) {
        view.addSubview(magnifierView)
        view.addSubview(_bottomLeftLabel)
        view.addSubview(_bottomRightLabel)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            magnifierView.topAnchor.constraint(equalTo: view.topAnchor),
            magnifierView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            magnifierView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            magnifierView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            _bottomLeftLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            _bottomLeftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            _bottomLeftLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5, constant: -4),
            
            _bottomRightLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            _bottomRightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            _bottomRightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: _bottomLeftLabel.trailingAnchor, constant: 8),
        ])
    }
    
    // MARK: -

    override func loadView() {
        let v = NSVisualEffectView(frame: NSMakeRect(0, 0, 300, 300))
        v.wantsLayer = true
        v.material = .sidebar
        v.blendingMode = .behindWindow
        view = v
    }
    
    override func viewDidLoad() {
        setupSubviews(in: view)
        setupDefaults()
    }
    
    // MARK: - Loading User Settings
    
    func setupDefaults() {
        magnifierView.magnificationFactor = DefaultsController.shared.retrive(.magnificationFactor)
        magnifierView.showGrid = DefaultsController.shared.retrive(.showGrid)
        magnifierView.showHotSpot = DefaultsController.shared.retrive(.showHotSpot)
        showMouseCoordinate = DefaultsController.shared.retrive(.showMouseCoordinate)
        mouseCoordinateInPixel = DefaultsController.shared.retrive(.mouseCoordinateInPixel)
        screensHasSeparateCooridinate = DefaultsController.shared.retrive(.screensHasSeparateCooridinate)
        isMouseCoordinateFlipped = DefaultsController.shared.retrive(.isMouseCoordinateFlipped)
        
        DefaultsController.shared.addSubscriber(self)
    }
    
    func defaultsController(_ controller: DefaultsController, didChangeDefaultWithKeyPath keyPath: String) {
        switch keyPath {
            case Default<CGFloat>.magnificationFactor.keyPath:
                let magnificationFactor = controller.retrive(.magnificationFactor)
                magnifierView.magnificationFactor = magnificationFactor
            
            case Default<Bool>.showMouseCoordinate.keyPath:
                showMouseCoordinate = controller.retrive(.showMouseCoordinate)
            
            case Default<Bool>.mouseCoordinateInPixel.keyPath:
                mouseCoordinateInPixel = controller.retrive(.mouseCoordinateInPixel)
            
            case Default<Bool>.screensHasSeparateCooridinate.keyPath:
                screensHasSeparateCooridinate = controller.retrive(.screensHasSeparateCooridinate)
            
            case Default<Bool>.isMouseCoordinateFlipped.keyPath:
                isMouseCoordinateFlipped = controller.retrive(.isMouseCoordinateFlipped)
            
            default: ()
        }
    }
    
//    public var mouseCoordinatesInPixel: Bool = true
    
    // MARK: - Responding to Keyboard & Mouse / Trackpad Events
    
    override func scrollWheel(with event: NSEvent) {
        setMagnification(to: magnifierView.magnificationFactor - event.deltaY)
    }
    
    func setMagnification(to magnificationFactor: CGFloat) {
        let clamped = max(1, min(magnificationFactor, 128))
        DefaultsController.shared.set(.magnificationFactor, to: clamped)
    }
    
}

extension MagnifierViewController: MagnifierViewDelegate {
    
    func magnifierView(_ view: MagnifierView, didUpdateMouseLocation location: NSPoint, flippedLocation: NSPoint) {
        guard showMouseCoordinate else { return }
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(location, $0.frame, false) }) else {
            _bottomLeftLabel.stringValue = "(-, -)"
            return
        }
        
        let pixelWidth = 1 / screen.backingScaleFactor
        
        var x: CGFloat
        var y: CGFloat
        
        switch (screensHasSeparateCooridinate, isMouseCoordinateFlipped) {
            case (true, _):
                let point = screen.convert(location, from: nil, flipped: isMouseCoordinateFlipped)
                x = floor(point.x, to: pixelWidth).clamped(to: 0..<screen.frame.width, by: pixelWidth)
                y = floor(point.y, to: pixelWidth).clamped(to: 0..<screen.frame.height, by: pixelWidth)
                
                if mouseCoordinateInPixel {
                    x *= screen.backingScaleFactor
                    y *= screen.backingScaleFactor
                }
            
            case (false, true):
                x = floor(flippedLocation.x, to: pixelWidth)
                y = floor(flippedLocation.y, to: pixelWidth)
            
            case (false, false):
                x = floor(location.x, to: pixelWidth)
                y = floor(location.y, to: pixelWidth)
        }
        
        if screen.backingScaleFactor == 1 || screensHasSeparateCooridinate && mouseCoordinateInPixel {
            _bottomLeftLabel.stringValue = String(format: "(%.0f, %.0f)", x, y)
        } else {
            _bottomLeftLabel.stringValue = String(format: "(%.1f, %.1f)", x, y)
        }
        
        _bottomLeftLabel.stringValue += screensHasSeparateCooridinate && mouseCoordinateInPixel ? "px" : "pt"
    }
    
    func magnifierView(_ view: MagnifierView, color: NSColor?, atLocation loactionInPoint: NSPoint) {
        if let color = color {
            _bottomRightLabel.stringValue = String(format: "sRGB(%.3f, %.3f, %.3f)", color.redComponent, color.greenComponent, color.blueComponent)
        } else {
            _bottomRightLabel.stringValue = "(-, -, -)"
        }
    }
    
}
