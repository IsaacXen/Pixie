import Cocoa

/// The window controller of the main magnifier window.
class MagnifierWindowController: NSWindowController, NSWindowDelegate {
    
    // MARK: - Loading Window
    
    override func loadWindow() {
        window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: true)
        window?.minSize = NSSize(width: 300, height: 300)
        // TODO: make floating window an option on main menu
//        window?.level = .floating
        window?.collectionBehavior = [.init(rawValue: 0), .managed, .participatesInCycle]
        window?.delegate = self
        window?.title = "Pixie"
        window?.titlebarAppearsTransparent = true
    }
    
    override func windowDidLoad() {
        // load content view conteoller
        contentViewController = MagnifierViewController()
        // setup frame autosave
        shouldCascadeWindows = false
        windowFrameAutosaveName = "magnifierWindow"
        // setup tracking area
        updateTrackingAreas()
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        updateTrackingAreas()
    }
    
    
    
    // MARK: - Tracking Area

    private var _trackingArea: NSTrackingArea?
    
    private func updateTrackingAreas() {
        guard let contentView = window?.contentView else { return }
        
        if let tr = _trackingArea {
            contentView.removeTrackingArea(tr)
        }
        
        _trackingArea = NSTrackingArea(rect: contentView.frame, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        
        contentView.addTrackingArea(_trackingArea!)
    }
    
    // MARK: - Event Handling
    
    // 1. Show or hide window titlebar when mouse entered and exited.
    
    override func mouseEntered(with event: NSEvent) {
        _titleBar?.animator().alphaValue = 1
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        _titleBar?.animator().alphaValue = 0
        super.mouseExited(with: event)
    }
    
    private var _titleBar: NSView? {
        window?.standardWindowButton(.closeButton)?.superview?.superview
    }
    
    // MARK: - Init
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
}
