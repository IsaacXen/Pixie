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
    
    @IBAction func setMagnification(_ sender: NSMenuItem) {
        setMagnification(to: CGFloat(sender.tag))
    }
    
    @IBAction func toggleGrid(_ sender: NSMenuItem) {
        magnifierView.showGrid.toggle()
        DefaultsController.shared.set(.showGrid, to: magnifierView.showGrid)
    }
    
    @IBAction func toggleHotSpot(_ sender: NSMenuItem) {
        magnifierView.showHotSpot.toggle()
        DefaultsController.shared.set(.showHotSpot, to: magnifierView.showHotSpot)
    }
    
    @IBAction func toggleMouseCoordinate(_ sender: NSMenuItem) {
        showMouseCoordinate.toggle()
        DefaultsController.shared.set(.showMouseCoordinate, to: showMouseCoordinate)
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
            case #selector(increaseMagnification), #selector(fastIncreaseMagnification):
                return magnifierView.magnificationFactor < 128
                
            case #selector(decreaseMagnification), #selector(fastDecreaseMagnification):
                return magnifierView.magnificationFactor > 1
             
            case #selector(toggleGrid):
                menuItem.title = magnifierView.canShowGrid ? magnifierView.showGrid ? "Hide Grid" : "Show Grid" : "Show Grid"
                return magnifierView.canShowGrid

            case #selector(toggleHotSpot):
                menuItem.title = magnifierView.showHotSpot ? "Hide Mouse Hot-Spot" : "Show Mouse Hot-Spot"
                return true

            case #selector(toggleMouseCoordinate):
                menuItem.title = showMouseCoordinate ? "Hide Mouse Coordinate" : "Show Mouse Coordinate"
                return true
            
            default:
                return true
        }
    }
    
}
