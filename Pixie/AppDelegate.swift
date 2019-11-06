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
            alert.messageText = .localized("alert.permission.text")
            alert.informativeText = .localized("alert.permission.info")
            alert.addButton(withTitle: .localized("alert.permission.allow"))
            alert.addButton(withTitle: .localized("alert.common.ignore"))
            alert.beginSheetModal(for: window) { response in
                switch response {
                    case .alertFirstButtonReturn:
                        // currently there's no anchor to Screen Recording provided.
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
