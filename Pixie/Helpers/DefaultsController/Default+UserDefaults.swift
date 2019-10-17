import Foundation

extension Default {
    
    static var floatingMagnifierWindow: Default<Bool> {
        return .init("floatingMagnifierWindow", false)
    }
    
    static var magnificationFactor: Default<CGFloat> {
        return .init("magnificationFactor", 16)
    }
    
}
