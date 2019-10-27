import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let magnifierWindowController = MagnifierWindowController()
        
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        magnifierWindowController.showWindow(nil)
        
        // check for authorization status
        if ScreenCapture.authorizationStatus == .denied, let window = magnifierWindowController.window {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = NSLocalizedString("alert.permission.text", comment: "title")
            alert.informativeText = NSLocalizedString("alert.permission.info", comment: "body")
            alert.addButton(withTitle: NSLocalizedString("alert.permission.allow", comment: "button"))
            alert.addButton(withTitle: NSLocalizedString("alert.common.ignore", comment: "button"))
            alert.beginSheetModal(for: window) { response in
                switch response {
                    case .alertFirstButtonReturn:
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
                    
                    default: ()
                }
            }
        }
    }

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
