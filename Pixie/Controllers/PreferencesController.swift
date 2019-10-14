import Foundation

protocol DefaultsControllerSubscriber: class {
    func defaultsController(_ controller: DefaultsController, didChange default: Default<Codable>)
}

class DefaultsController: NSObject {
    
    public static let shared = DefaultsController()
    
    func set<T>(_ default: Default<T>, to newValue: T) where T: Codable {
        guard !`default`.readOnly else { return }
        
        if let encoded = try? PropertyListEncoder().encode(newValue) {
            UserDefaults.standard.set(encoded, forKey: `default`.keyPath)
        } else {
            
        }
    }
    
}

struct Default<T> {
    
    let keyPath: String
    let defaultValue: T
    let readOnly: Bool
    
    init(_ keyPath: String, _ defaultValue: T, readOnly: Bool = false) {
        self.keyPath = keyPath
        self.defaultValue = defaultValue
        self.readOnly = readOnly
    }

}

extension Default {
    
    
    
}
