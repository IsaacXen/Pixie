import Foundation

extension Default {
    
    static var quitWhenClose: Default<Bool> {
        return .init("quitWhenClose", true)
    }
    
    static var floatingMagnifierWindow: Default<Bool> {
        return .init("floatingMagnifierWindow", false)
    }
    
    static var magnificationFactor: Default<CGFloat> {
        return .init("magnificationFactor", 16)
    }
    
    static var showGrid: Default<Bool> {
        return .init("showGrid", false)
    }
    
    static var showHotSpot: Default<Bool> {
        return .init("showHotSpot", true)
    }
    
    static var showMouseCoordinate: Default<Bool> {
        return .init("showMouseCoordinate", false)
    }
    
    static var mouseCoordinateInPixel: Default<Bool> {
        return .init("mouseCoordinateInPixel", false)
    }
    
    static var screensHasSeparateCooridinate: Default<Bool> {
        return .init("screensHasSeparateCooridinate", false)
    }
    
    static var isMouseCoordinateFlipped: Default<Bool> {
        return .init("isMouseCoordinateFlipped", true)
    }
    
    static var showColorValue: Default<Bool> {
        return .init("showColorValue", false)
    }
    
}
