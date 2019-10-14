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
