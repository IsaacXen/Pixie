import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let magnifierWindowController = MagnifierWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        magnifierWindowController.showWindow(nil)
    }

    /// Hnadle reopen when clicking dock icon and launching from finder
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard !flag else { return true }
        
        if let window = sender.windows.first {
            window.makeKeyAndOrderFront(self)
        } else {
            magnifierWindowController.showWindow(self)
        }
        
        return false
    }
    
}

extension AppDelegate: NSMenuItemValidation {
    
    @IBAction func toggleQuitWhenClose(_ sender: NSMenuItem?) {
        let quitWhenClose = DefaultsController.shared.retrive(.quitWhenClose)
        DefaultsController.shared.set(.quitWhenClose, to: !quitWhenClose)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(toggleQuitWhenClose):
                menuItem.state = DefaultsController.shared.retrive(.quitWhenClose) ? .on : .off
                return true
            
            default:
                return true
        }
    }
    
}
