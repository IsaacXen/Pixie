import FoundationExtended
import Cocoa

class MagnifierViewController: NSViewController, DefaultsControllerSubscriber {

    var showMouseCoordinate: Bool = false {
        didSet {
            _bottomLeftLabel.isHidden = !showMouseCoordinate
        }
    }
    
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
        
        DefaultsController.shared.addSubscriber(self)
    }
    
    func defaultsController(_ controller: DefaultsController, didChangeDefaultWithKeyPath keyPath: String) {
        switch keyPath {
            case Default<CGFloat>.magnificationFactor.keyPath:
                let magnificationFactor = controller.retrive(.magnificationFactor)
                magnifierView.magnificationFactor = magnificationFactor
            
            case Default<Bool>.showMouseCoordinate.keyPath:
                showMouseCoordinate = controller.retrive(.showMouseCoordinate)
            
            default: ()
        }
    }
    
    public var mouseCoordinatesInPixel: Bool = true
    
    // MARK: - Responding to Keyboard & Mouse / Trackpad Events
    
//    override func scrollWheel(with event: NSEvent) {
//        setMagnification(to: magnifierView.magnificationFactor - event.deltaY)
//    }
    
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
        
        _bottomLeftLabel.stringValue = String(format: "(%.1f, %.1f)", floor(flippedLocation.x, to: 1 / screen.backingScaleFactor), floor(flippedLocation.y, to: 1 / screen.backingScaleFactor))
    }
    
    func magnifierView(_ view: MagnifierView, color: NSColor?, atLocation loactionInPoint: NSPoint) {
        if let color = color {
            _bottomRightLabel.stringValue = String(format: "sRGB(%.3f, %.3f, %.3f)", color.redComponent, color.greenComponent, color.blueComponent)
        } else {
            _bottomRightLabel.stringValue = "(-, -, -)"
        }
    }
    
}
