import Cocoa
import PreferencesController

extension Preference {
    
    static var quitWhenClose: Preference<Bool> {
        return .readWrite("quitWhenClose", defaultValue: true)
    }

    static var floatingMagnifierWindow: Preference<Bool> {
        return .readWrite("floatingMagnifierWindow", defaultValue: false)
    }

    static var magnificationFactor: Preference<CGFloat> {
        return .readWrite("magnificationFactor", defaultValue: 16)
    }

    static var showGrid: Preference<Bool> {
        return .readWrite("showGrid", defaultValue: false)
    }

    static var showHotSpot: Preference<Bool> {
        return .readWrite("showHotSpot", defaultValue: true)
    }

    static var showMouseCoordinate: Preference<Bool> {
        return .readWrite("showMouseCoordinate", defaultValue: false)
    }

    static var mouseCoordinateInPixel: Preference<Bool> {
        return .readWrite("mouseCoordinateInPixel", defaultValue: false)
    }

    static var screensHasSeparateCooridinate: Preference<Bool> {
        return .readWrite("screensHasSeparateCooridinate", defaultValue: false)
    }

    static var isMouseCoordinateFlipped: Preference<Bool> {
        return .readWrite("isMouseCoordinateFlipped", defaultValue: true)
    }

    static var showColorValue: Preference<Bool> {
        return .readWrite("showColorValue", defaultValue: false)
    }

    static var colorModel: Preference<ColorModel> {
        return .readWrite("colorModel", defaultValue: .rgb)
    }

    static var colorProfiles: Preference<[ColorModel: String]> {
        return .readWrite("colorProfiles", defaultValue: [
            .rgb: "Device RGB",
            .grayscale: "Device Gray",
            .cmyk: "Device CMYK",
            .hsb: "Device RGB"
        ])
    }

}
