import Cocoa

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
    
    @IBAction func setMagnification(_ sender: NSMenuItem?) {
        if let tag = sender?.tag {
            setMagnification(to: CGFloat(tag))
        }
    }
    
    @IBAction func toggleGrid(_ sender: Any?) {
        magnifierView.showGrid.toggle()
        DefaultsController.shared.set(.showGrid, to: magnifierView.showGrid)
    }
    
    @IBAction func toggleHotSpot(_ sender: Any?) {
        magnifierView.showHotSpot.toggle()
        DefaultsController.shared.set(.showHotSpot, to: magnifierView.showHotSpot)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(increaseMagnification), #selector(fastIncreaseMagnification):
                return magnifierView.magnificationFactor < 128
                
            case #selector(decreaseMagnification), #selector(fastDecreaseMagnification):
                return magnifierView.magnificationFactor > 1
             
            case #selector(toggleGrid):
                menuItem.state = magnifierView.canShowGrid ? magnifierView.showGrid ? .on : .off : .off
                return magnifierView.canShowGrid

            case #selector(toggleHotSpot):
                menuItem.state = magnifierView.showHotSpot ? .on : .off
                return true

            default:
                return true
        }
    }
    
}
