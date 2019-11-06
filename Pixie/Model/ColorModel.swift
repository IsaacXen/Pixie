import Foundation
import PreferencesController

enum ColorModel: String, PropertyListRepresentable, LosslessStringConvertible {
    case grayscale
    case rgb
    case cmyk
    case hsb
        
    var propertyListEncoded: Any {
        rawValue
    }
    
    static func decode(fromPropertyList encoded: Any) -> ColorModel? {
        ColorModel(rawValue: encoded as? String ?? "")
    }
    
    var description: String {
        rawValue
    }
    
    init?(_ description: String) {
        self.init(rawValue: description)
    }
}
