import Foundation

extension Default {
    
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
    
}
