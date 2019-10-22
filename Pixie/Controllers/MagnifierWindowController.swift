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
    }
    
    override func windowDidLoad() {
        // load content view conteoller
        contentViewController = MagnifierViewController()
        // setup frame autosave
        shouldCascadeWindows = false
        windowFrameAutosaveName = "magnifierWindow"
        
        let shouldFloat = DefaultsController.shared.retrive(.floatingMagnifierWindow)
        window?.level = shouldFloat ? .floating : .normal
    }
    
    func windowWillClose(_ notification: Notification) {
        if DefaultsController.shared.retrive(.quitWhenClose) {
            NSApp.terminate(nil)
        }
    }
    
    // MARK: - Init
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
}

extension MagnifierWindowController: NSMenuItemValidation {
   
    @IBAction func toggleWindowFloating(_ sender: NSMenuItem?) {
        let isFloating = window?.level == .some(.floating)
        window?.level = isFloating ? .normal : .floating
        
        DefaultsController.shared.set(.floatingMagnifierWindow, to: !isFloating)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(toggleWindowFloating):
                menuItem.state = window?.level == .some(.floating) ? .on : .off
                return true
            
            default:
                return true
        }
    }
    
}
