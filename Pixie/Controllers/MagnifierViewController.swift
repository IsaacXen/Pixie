import Cocoa
import FoundationExtended
import CocoaExtended
import PreferencesController

class MagnifierViewController: NSViewController, PreferencesControllerSubscriber {
    
    var showMouseCoordinate: Bool = false {
        didSet {
            _bottomLeftLabel.isHidden = !showMouseCoordinate
        }
    }
    
    var mouseCoordinateInPixel: Bool = false
    
    var screensHasSeparateCooridinate: Bool = false
    
    var isMouseCoordinateFlipped: Bool = true
    
    var showColorValue: Bool = false {
        didSet {
            _bottomRightLabel.isHidden = !showColorValue
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
        setupPreferences()
    }
    
    // MARK: - Loading User Settings
    
    func setupPreferences() {
        magnifierView.magnificationFactor = PreferencesController.shared.retrive(.magnificationFactor)
        magnifierView.showGrid = PreferencesController.shared.retrive(.showGrid)
        magnifierView.showHotSpot = PreferencesController.shared.retrive(.showHotSpot)
        showMouseCoordinate = PreferencesController.shared.retrive(.showMouseCoordinate)
        mouseCoordinateInPixel = PreferencesController.shared.retrive(.mouseCoordinateInPixel)
        screensHasSeparateCooridinate = PreferencesController.shared.retrive(.screensHasSeparateCooridinate)
        isMouseCoordinateFlipped = PreferencesController.shared.retrive(.isMouseCoordinateFlipped)
        showColorValue = PreferencesController.shared.retrive(.showColorValue)
        
        PreferencesController.shared.addSubscriber(self)
    }
    
    func preferencesController(_ controller: PreferencesController, didChangePreferenceWithKey key: String, newValue: PropertyListRepresentable, oldValue: PropertyListRepresentable) {
        switch key {
            case Preference<CGFloat>.magnificationFactor.key:
                let magnificationFactor = controller.retrive(.magnificationFactor)
                magnifierView.magnificationFactor = magnificationFactor
            
            case Preference<Bool>.showMouseCoordinate.key:
                showMouseCoordinate = controller.retrive(.showMouseCoordinate)
            
            case Preference<Bool>.mouseCoordinateInPixel.key:
                mouseCoordinateInPixel = controller.retrive(.mouseCoordinateInPixel)
            
            case Preference<Bool>.screensHasSeparateCooridinate.key:
                screensHasSeparateCooridinate = controller.retrive(.screensHasSeparateCooridinate)
            
            case Preference<Bool>.isMouseCoordinateFlipped.key:
                isMouseCoordinateFlipped = controller.retrive(.isMouseCoordinateFlipped)
            
            case Preference<Bool>.showColorValue.key:
                showColorValue = controller.retrive(.showColorValue)

            default: ()
        }
    }
    
    // MARK: - Responding to Keyboard & Mouse / Trackpad Events
    
    override func scrollWheel(with event: NSEvent) {
        setMagnification(to: magnifierView.magnificationFactor - event.deltaY)
    }
    
    func setMagnification(to magnificationFactor: CGFloat) {
        let clamped = max(1, min(magnificationFactor, 128))
        PreferencesController.shared.save(clamped, to: .magnificationFactor)
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
        
    }
    
    func magnifierView(_ view: MagnifierView, colorAtMouseHotSpot color: NSColor) {
        guard showColorValue else { return }
        
        if let color = ColorValueController.shared.converColorToSelectedProfile(color) {
            _bottomRightLabel.stringValue = ColorValueController.shared.colorDescriptionWithSelectedProfile(color)
        }
    }
    
}
