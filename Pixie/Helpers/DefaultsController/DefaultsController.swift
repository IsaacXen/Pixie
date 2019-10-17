import Foundation

class DefaultsController: NSObject {
    
    public static let shared = DefaultsController()
    
    func set<T>(_ default: Default<T>, to newValue: T) {
        guard !`default`.readOnly else {
            return
        }
        
        switch newValue {
            case is Bool, is Float, is Double, is CGFloat:
                UserDefaults.standard.set(newValue, forKey: `default`.keyPath)
            
            default:
                print("unsupport value type")
                return
        }
        
        _subscriber.compactForEach(AnyObject.self) { subscriber in
            (subscriber as? DefaultsControllerSubscriber)?.defaultsController(self, didChangeDefaultWithKeyPath: `default`.keyPath)
        }
    }
    
    func retrive<T>(_ default: Default<T>) -> T {
        guard !`default`.readOnly else {
            return `default`.defaultValue
        }
        
        guard let object = UserDefaults.standard.object(forKey: `default`.keyPath) else {
            return `default`.defaultValue
        }
        
        switch object {
            case is Bool, is Float, is Double, is CGFloat:
                return object as! T
            
            default:
                print("unhandled value type \(String(describing: object))")
        }
        
        return `default`.defaultValue
    }
    
    //
    
    private let _subscriber = NSPointerArray.weakObjects()
    
    func addSubscriber(_ newSubscriber: DefaultsControllerSubscriber) {
        _subscriber.add(newSubscriber as AnyObject)
        print(#function, _subscriber.count)
    }
    
    func removeSubscriber(_ subscriber: DefaultsControllerSubscriber) {
        _subscriber.remove(subscriber as AnyObject)
        print(#function, _subscriber.count)
    }
    
}
