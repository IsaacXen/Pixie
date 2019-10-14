import Cocoa

class MagnifierViewController: NSViewController {

    public var magnificationFactor: CGFloat = 32 {
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
        
        DisplayLink.shared.addSubscriber(magnifierView)
        
        magnificationFactor = 32
        
        NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: view.window, queue: .main, using: applicationDidChangeOcclusionState)
    }

    func applicationDidChangeOcclusionState(_ notification: Notification) {
        guard let sender = notification.object as? NSWindow else { return }
        
        if sender.occlusionState.contains(.visible) {
            DisplayLink.shared.addSubscriber(magnifierView)
        } else {
            DisplayLink.shared.removeSubscriber(magnifierView)
        }
    }
    
}

