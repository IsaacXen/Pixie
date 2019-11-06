import Cocoa
import PreferencesController

class ColorValueController: NSObject, PreferencesControllerSubscriber {
    
    static let shared = ColorValueController()
    
    private var _selectedColorModel: ColorModel = .rgb
    
    var selectedColorModel: ColorModel {
        get { _selectedColorModel }
        set { PreferencesController.shared.save(newValue, to: .colorModel) }
    }
    
    private(set) var selectedColorProfiles: [ColorModel: String] = [:]

    func colorSpaces(for colorModel: ColorModel) -> [NSColorSpace] {
        switch colorModel {
            case .grayscale:
                return NSColorSpace.availableColorSpaces(with: .gray)
            case .rgb, .hsb:
                return NSColorSpace.availableColorSpaces(with: .rgb)
            case .cmyk:
                return NSColorSpace.availableColorSpaces(with: .cmyk)
        }
    }
    
    func colorSpace(withName name: String) -> NSColorSpace? {
        let profiles = colorSpaces(for: selectedColorModel)
        
        return profiles.first {
            $0.localizedName != nil && $0.localizedName == name
        }
    }
    
    func set(colorSpace: NSColorSpace, for colorModel: ColorModel) {
        selectedColorProfiles = PreferencesController.shared.retrive(.colorProfiles)
        selectedColorProfiles[colorModel] = colorSpace.localizedName ?? ""
        PreferencesController.shared.save(selectedColorProfiles, to: .colorProfiles)
    }
    
    func converColorToSelectedProfile(_ color: NSColor) -> NSColor? {
        if let colorProfile = colorSpace(withName: selectedColorProfiles[_selectedColorModel] ?? "") {
            return color.usingColorSpace(colorProfile)
        } else {
            return nil
        }
    }
    
    func colorDescriptionWithSelectedProfile(_ color: NSColor) -> String {
        switch _selectedColorModel {
            case .rgb:
                return String(format: "RGB(%.2f, %.2f, %.2f)", color.redComponent, color.greenComponent, color.blueComponent)
            case .hsb:
                return String(format: "HSB(%.2f, %.2f, %.2f)", color.hueComponent, color.saturationComponent, color.brightnessComponent)
            case .cmyk:
                return String(format: "CMYK(%.2f, %.2f, %.2f, %.2f)", color.cyanComponent, color.magentaComponent, color.yellowComponent, color.blackComponent)
            case .grayscale:
                return String(format: "GS(%.2f)", 1 - color.whiteComponent)
        }
    }
    
    private override init() {
        super.init()
        
        _selectedColorModel = PreferencesController.shared.retrive(.colorModel)
        selectedColorProfiles = PreferencesController.shared.retrive(.colorProfiles)
        
        PreferencesController.shared.addSubscriber(self)
    }
    
    func preferencesController(_ controller: PreferencesController, didChangePreferenceWithKey key: String, newValue: PropertyListRepresentable, oldValue: PropertyListRepresentable) {
        if key == Preference<ColorModel>.colorModel.key {
            _selectedColorModel = controller.retrive(.colorModel)
        } else if key == Preference<[ColorModel: String]>.colorProfiles.key {
            selectedColorProfiles = controller.retrive(.colorProfiles)
        }
    }

}
