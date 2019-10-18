import Cocoa

/// The window controller of the main magnifier window.
class MagnifierWindowController: NSWindowController, NSWindowDelegate {
    
    // MARK: - Loading Window
    
    override func loadWindow() {
        window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: true)
        window?.minSize = NSSize(width: 300, height: 300)
        window?.collectionBehavior = [.init(rawValue: 0), .managed, .participatesInCycle, .fullScreenPrimary]
        window?.delegate = self
        window?.title = "Pixie"
        window?.tabbingMode = .disallowed
        
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
    }
    
    override func windowDidLoad() {
        // load content view conteoller
        contentViewController = MagnifierViewController()
        // setup frame autosave
        shouldCascadeWindows = false
        windowFrameAutosaveName = "magnifierWindow"
        
        let shouldFloat = DefaultsController.shared.retrive(.floatingMagnifierWindow)
        window?.level = shouldFloat ? .screenSaver : .normal
        
        // setup tracking area
        updateTrackingAreas()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3)) { [weak self] in
            if !(self?.window?.frame.contains(NSEvent.mouseLocation) ?? false) {
                self?._titleBar?.animator().alphaValue = 0
            }
        }
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        updateTrackingAreas()
    }

    func windowWillEnterFullScreen(_ notification: Notification) {
        updateTrackingAreas()
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        _titleBar?.alphaValue = 1
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        _titleBar?.alphaValue = 0
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        updateTrackingAreas()
    }
    
    // MARK: - Tracking Area

    private var _trackingArea: NSTrackingArea?
    
    private func updateTrackingAreas() {
        guard
            let window = window,
            let contentView = window.contentView
        else { return }
        
        if let tr = _trackingArea {
            contentView.removeTrackingArea(tr)
        }
        
        if !window.styleMask.contains(.fullScreen) {
            _trackingArea = NSTrackingArea(rect: contentView.frame, options: [.activeInActiveApp, .mouseEnteredAndExited], owner: self, userInfo: nil)
            contentView.addTrackingArea(_trackingArea!)
        }
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

extension MagnifierWindowController: NSMenuItemValidation {
   
    @IBAction func toggleWindowFloating(_ sender: NSMenuItem?) {
        let isFloating = window?.level == .some(.screenSaver)
        window?.level = isFloating ? .normal : .screenSaver
        
        DefaultsController.shared.set(.floatingMagnifierWindow, to: !isFloating)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(toggleWindowFloating):
                menuItem.state = window?.level == .some(.screenSaver) ? .on : .off
                return true
            
            default:
                return true
        }
    }
    
}
