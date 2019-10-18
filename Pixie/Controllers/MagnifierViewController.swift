import Cocoa

class MagnifierViewController: NSViewController {

    public var magnificationFactor: CGFloat = 1 {
        didSet {
            magnifierView.magnificationFactor = magnificationFactor
            hudView.magnificationFactor = magnificationFactor
        }
    }
    
    override func loadView() {
        let v = NSVisualEffectView(frame: NSMakeRect(0, 0, 300, 300))
        v.material = .sidebar
        v.state = .active
        v.blendingMode = .behindWindow
        view = v
    }
    
    private let magnifierView: MagnifierView = {
        let view = MagnifierView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private let hudView: HudView = {
        let view = HudView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
        
    override func viewDidLoad() {
        view.addSubview(magnifierView)
        view.addSubview(hudView)
        
        NSLayoutConstraint.activate([
            magnifierView.topAnchor.constraint(equalTo: view.topAnchor),
            magnifierView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            magnifierView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            magnifierView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            hudView.topAnchor.constraint(equalTo: view.topAnchor),
            hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hudView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hudView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
                
        setupDefaults()
        
//        NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: view.window, queue: .main, using: applicationDidChangeOcclusionState)
        
        DisplayLink.shared.addSubscriber(magnifierView)
        
    }
    
    func setupDefaults() {
        magnificationFactor = DefaultsController.shared.retrive(.magnificationFactor)
        hudView.showGrid = DefaultsController.shared.retrive(.showGrid)
        hudView.showHotSpot = DefaultsController.shared.retrive(.showHotSpot)
        
        DefaultsController.shared.addSubscriber(self)
    }

    func applicationDidChangeOcclusionState(_ notification: Notification) {
        guard let sender = notification.object as? NSWindow else { return }
        
        if sender.occlusionState.contains(.visible) {
            DisplayLink.shared.addSubscriber(magnifierView)
        } else {
            DisplayLink.shared.removeSubscriber(magnifierView)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        setMagnification(to: magnificationFactor - event.deltaY)
    }
    
    func setMagnification(to magnificationFactor: CGFloat) {
        let clamped = max(1, min(magnificationFactor, 128))
        DefaultsController.shared.set(.magnificationFactor, to: clamped)
    }
    
}



// MARK: - Responder Chain Action Handling

extension MagnifierViewController: NSMenuItemValidation {
    
    @IBAction func increaseMagnification(_ sender: NSMenuItem?) {
        setMagnification(to: floor(magnificationFactor) + 1)
    }
    
    @IBAction func fastIncreaseMagnification(_ sender: NSMenuItem?) {
        var factor: CGFloat = 1
        
        while magnificationFactor >= factor {
            factor *= 2
        }
        
        setMagnification(to: factor)
    }
    
    @IBAction func decreaseMagnification(_ sender: NSMenuItem?) {
        setMagnification(to: floor(magnificationFactor) - 1)
    }

    @IBAction func fastDecreaseMagnification(_ sender: NSMenuItem?) {
        var factor: CGFloat = 1
        
        while magnificationFactor > factor * 2 {
            factor *= 2
        }
        
        setMagnification(to: factor)
    }
    
    @IBAction func setMagnification(_ sender: NSMenuItem?) {
        if let tag = sender?.tag {
            setMagnification(to: CGFloat(tag))
        }
    }
    
    @IBAction func toggleGrid(_ sender: Any?) {
        hudView.showGrid.toggle()
        DefaultsController.shared.set(.showGrid, to: hudView.showGrid)
    }
    
    @IBAction func toggleHotSpot(_ sender: Any?) {
        hudView.showHotSpot.toggle()
        DefaultsController.shared.set(.showHotSpot, to: hudView.showHotSpot)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(increaseMagnification), #selector(fastIncreaseMagnification):
                return magnificationFactor < 128
                
            case #selector(decreaseMagnification), #selector(fastDecreaseMagnification):
                return magnificationFactor > 1
             
            case #selector(toggleGrid):
                menuItem.state = hudView.canShowGrid ? hudView.showGrid ? .on : .off : .off
                return hudView.canShowGrid
            
            case #selector(toggleHotSpot):
                menuItem.state = hudView.showHotSpot ? .on : .off
            
            default:
                return true
        }
        
        return true
    }
}

extension MagnifierViewController: DefaultsControllerSubscriber {
    
    func defaultsController(_ controller: DefaultsController, didChangeDefaultWithKeyPath keyPath: String) {
        switch keyPath {
            case Default<CGFloat>.magnificationFactor.keyPath:
                magnificationFactor = controller.retrive(.magnificationFactor)
            
            default: ()
        }
    }
    
}
