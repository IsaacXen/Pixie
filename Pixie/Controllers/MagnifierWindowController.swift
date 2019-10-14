import Cocoa

class MagnifierWindowController: NSWindowController, NSWindowDelegate {
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func loadWindow() {
        window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: true)
        window?.minSize = NSSize(width: 300, height: 300)
        window?.level = .floating
        window?.collectionBehavior = [.init(rawValue: 0), .managed, .participatesInCycle]
        window?.delegate = self
        window?.title = "Pixie"
    }
    
    override func windowDidLoad() {
        contentViewController = MagnifierViewController()
        updateTrackingAreas()
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        updateTrackingAreas()
    }
    
    // MARK: - Tracking Area

    private var _trackingArea: NSTrackingArea?
    
    func updateTrackingAreas() {
        guard let contentView = window?.contentView else { return }
        
        if let tr = _trackingArea {
            contentView.removeTrackingArea(tr)
        }
        
        _trackingArea = NSTrackingArea(rect: contentView.frame, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        
        contentView.addTrackingArea(_trackingArea!)
    }
    
    // MARK: - Event Handling
    
    override func mouseEntered(with event: NSEvent) {
        titleBar?.animator().alphaValue = 1
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        titleBar?.animator().alphaValue = 0
        super.mouseExited(with: event)
    }
    
    var titleBar: NSView? {
        window?.standardWindowButton(.closeButton)?.superview?.superview
    }
    
}
