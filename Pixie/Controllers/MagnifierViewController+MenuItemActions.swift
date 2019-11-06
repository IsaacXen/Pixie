import Cocoa
import CocoaExtended
import PreferencesController

extension MagnifierViewController: NSMenuItemValidation {
    
    @IBAction func increaseMagnification(_ sender: NSMenuItem?) {
        setMagnification(to: floor(magnifierView.magnificationFactor) + 1)
    }
    
    @IBAction func fastIncreaseMagnification(_ sender: NSMenuItem?) {
        var factor: CGFloat = 1
        
        while magnifierView.magnificationFactor >= factor {
            factor *= 2
        }
        
        setMagnification(to: factor)
    }
    
    @IBAction func decreaseMagnification(_ sender: NSMenuItem?) {
        setMagnification(to: floor(magnifierView.magnificationFactor) - 1)
    }

    @IBAction func fastDecreaseMagnification(_ sender: NSMenuItem?) {
        var factor: CGFloat = 1
        
        while magnifierView.magnificationFactor > factor * 2 {
            factor *= 2
        }
        
        setMagnification(to: factor)
    }
    
    @IBAction func setMagnification(_ sender: NSMenuItem) {
        setMagnification(to: CGFloat(sender.tag))
    }
    
    @IBAction func toggleGrid(_ sender: NSMenuItem) {
        magnifierView.showGrid.toggle()
        PreferencesController.shared.save(magnifierView.showGrid, to: .showGrid)
        
    }
    
    @IBAction func toggleHotSpot(_ sender: NSMenuItem) {
        magnifierView.showHotSpot.toggle()
        PreferencesController.shared.save(magnifierView.showHotSpot, to: .showHotSpot)
    }
    
    @IBAction func toggleMouseCoordinate(_ sender: NSMenuItem) {
        showMouseCoordinate.toggle()
        PreferencesController.shared.save(showMouseCoordinate, to: .showMouseCoordinate)
    }
    
    @IBAction func toggleMouseCoirdinateBetweenPixelAndPoint(_ sender: NSMenuItem) {
        switch sender.identifier?.rawValue {
            case "mouseCoordinateInPoint":
                mouseCoordinateInPixel = false
            
            case "mouseCoordinateInPixel":
                mouseCoordinateInPixel = true
            
            default: ()
        }
        
        PreferencesController.shared.save(mouseCoordinateInPixel, to: .mouseCoordinateInPixel)
    }
    
    @IBAction func toggleFlippedCoordinate(_ sender: NSMenuItem) {
        isMouseCoordinateFlipped.toggle()
        PreferencesController.shared.save(isMouseCoordinateFlipped, to: .isMouseCoordinateFlipped)
    }
    
    @IBAction func togglePrimarySeparateScreenCoordinate(_ sender: NSMenuItem) {
        switch sender.identifier?.rawValue {
            case "mouseCoordinateInPrimary":
                screensHasSeparateCooridinate = false
            
            case "mouseCoordinateInSeparate":
                screensHasSeparateCooridinate = true
            
            default: ()
        }
        
        PreferencesController.shared.save(screensHasSeparateCooridinate, to: .screensHasSeparateCooridinate)
    }
    
    @IBAction func toggleLockX(_ sender: NSMenuItem) {
        magnifierView.lockX.toggle()
    }
    
    @IBAction func toggleLockY(_ sender: NSMenuItem) {
        magnifierView.lockY.toggle()
    }
    
    @IBAction func toggleLockBoth(_ sender: NSMenuItem) {
        if magnifierView.lockX && magnifierView.lockY {
            magnifierView.lockX = false
            magnifierView.lockY = false
        } else {
            magnifierView.lockX = true
            magnifierView.lockY = true
        }
    }
    
    @IBAction func toggleFreeze(_ sender: NSMenuItem) {
        magnifierView.isFreezed.toggle()
    }
    
    @IBAction func toggleColorValue(_ sender: NSMenuItem) {
        showColorValue.toggle()
        PreferencesController.shared.save(showColorValue, to: .showColorValue)
    }
    
    @IBAction func toggleColorModel(_ sender: NSMenuItem) {
        guard let id = sender.identifier?.rawValue, let model = ColorModel(rawValue: id) else { return }
        ColorValueController.shared.selectedColorModel = model
    }
    
    @IBAction func toggleColorProfile(_ sender: NSMenuItem) {
        guard
            let colorProfileName = sender.identifier?.rawValue,
            let colorSpace = ColorValueController.shared.colorSpace(withName: colorProfileName)
        else { return }
        
        ColorValueController.shared.set(colorSpace: colorSpace, for: ColorValueController.shared.selectedColorModel)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(increaseMagnification), #selector(fastIncreaseMagnification):
                return magnifierView.magnificationFactor < 128
                
            case #selector(decreaseMagnification), #selector(fastDecreaseMagnification):
                return magnifierView.magnificationFactor > 1
             
            case #selector(toggleGrid):
                menuItem.title = magnifierView.canShowGrid ? magnifierView.showGrid ? .localized("view.hide-grid") : .localized("view.show-grid") : .localized("view.show-grid")
                return magnifierView.canShowGrid

            case #selector(toggleHotSpot):
                menuItem.title = magnifierView.showHotSpot ? .localized("view.hide-mouse-hotspot") : .localized("view.show-mouse-hotspot")

            case #selector(toggleMouseCoordinate):
                menuItem.title = showMouseCoordinate ? .localized("view.hide-mouse-coordinate") : .localized("view.show-mouse-coordinate")
            
            case #selector(toggleMouseCoirdinateBetweenPixelAndPoint):
                switch menuItem.identifier?.rawValue {
                    case "mouseCoordinateInPoint":
                        menuItem.state = screensHasSeparateCooridinate ? mouseCoordinateInPixel ? .off : .on : .on
                    
                    case "mouseCoordinateInPixel":
                        menuItem.state = screensHasSeparateCooridinate ? mouseCoordinateInPixel ? .on : .off : .off
                    
                    default: ()
                }
                return showMouseCoordinate && screensHasSeparateCooridinate
            
            case #selector(toggleFlippedCoordinate):
                menuItem.state = isMouseCoordinateFlipped ? .on : .off
                return showMouseCoordinate
            
            case #selector(togglePrimarySeparateScreenCoordinate):
                switch menuItem.identifier?.rawValue {
                    case "mouseCoordinateInPrimary":
                        menuItem.state = screensHasSeparateCooridinate ? .off : .on
                    
                    case "mouseCoordinateInSeparate":
                        menuItem.state = screensHasSeparateCooridinate ? .on : .off
                    
                    default: ()
                }
                return showMouseCoordinate
            
            case #selector(toggleLockX):
                menuItem.title = magnifierView.lockX ? .localized("view.unlock-x") : .localized("view.lock-x")
            
            case #selector(toggleLockY):
                menuItem.title = magnifierView.lockY ? .localized("view.unlock-y") : .localized("view.lock-y")
            
            case #selector(toggleLockBoth):
                menuItem.title = magnifierView.lockX && magnifierView.lockY ? .localized("view.unlock-both") : .localized("view.lock-both")
            
            case #selector(toggleFreeze):
                menuItem.title = magnifierView.isFreezed ? .localized("view.unfreeze") : .localized("view.freeze")
            
            case #selector(toggleColorValue):
                menuItem.title = showColorValue ? .localized("view.hide-color-value") : .localized("view.show-color-value")
            
            case #selector(toggleColorModel):
                let menuItemMode = ColorModel(rawValue: menuItem.identifier?.rawValue ?? "")
                menuItem.state = menuItemMode == ColorValueController.shared.selectedColorModel ? .on : .off
            
            case #selector(toggleColorProfile):
                guard let menuItemIdentifier = menuItem.identifier?.rawValue else { return false }
                let selectedColorProfile = ColorValueController.shared.selectedColorProfiles[ColorValueController.shared.selectedColorModel]
                menuItem.state = menuItemIdentifier == selectedColorProfile ? .on : .off
            
            default: ()
        }
        
        return true
    }
    
}
