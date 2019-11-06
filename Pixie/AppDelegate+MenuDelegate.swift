import Cocoa

extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        // TOOD: Need a way to check if the menu is what we want.
        // For now, we can do this without checking, because only one menu is pointing this as its delegate.
        
        // 1. remove existing populated items
        let startIndex = menu.indexOfItem(withTag: 2) + 1
        let endIndex = menu.items.count > startIndex ? menu.items.count : startIndex
        
        for index in (startIndex..<endIndex).reversed() {
            menu.removeItem(at: index)
        }
        
        // 2. populate menu items
        let colorModel = ColorValueController.shared.selectedColorModel
        let colorProfiles = ColorValueController.shared.colorSpaces(for: colorModel)
        
        for colorProfile in colorProfiles {
            let title = colorProfile.localizedName ?? "Untitled Profile"
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.identifier = NSUserInterfaceItemIdentifier(title)
            item.action = #selector(MagnifierViewController.toggleColorProfile(_:))
            menu.addItem(item)
        }
        
    }
    
}
