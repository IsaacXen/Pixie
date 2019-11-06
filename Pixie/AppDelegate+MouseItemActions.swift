import Cocoa
import PreferencesController

extension AppDelegate: NSMenuItemValidation {
    
    @IBAction func toggleQuitWhenClose(_ sender: NSMenuItem?) {
        let quitWhenClose = PreferencesController.shared.retrive(.quitWhenClose)
        PreferencesController.shared.save(!quitWhenClose, to: .quitWhenClose)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(toggleQuitWhenClose):
                menuItem.state = PreferencesController.shared.retrive(.quitWhenClose) ? .on : .off
                return true
            
            default:
                return true
        }
    }
    
}
