import Foundation

extension NSPointerArray {

    func firstIndex<Element>(of element: Element) -> Int? where Element: AnyObject {
        for index in 0..<count {
            if let pointer = pointer(at: index) {
                if element === Unmanaged<Element>.fromOpaque(pointer).takeUnretainedValue() {
                    return index
                }
            }
        }
        
        return nil
    }
    
    func contains<Element>(_ element: Element) -> Bool where Element: AnyObject {
        for index in 0..<count {
            if let pointer = pointer(at: index) {
                if element === Unmanaged<Element>.fromOpaque(pointer).takeUnretainedValue() {
                    return true
                }
            }
        }
        
        return false
    }
    
    func add<Element>(_ newElement: Element) where Element: AnyObject {
        addPointer(Unmanaged.passUnretained(newElement).toOpaque())
    }
    
    func remove<Element>(_ element: Element) where Element: AnyObject {
        if let index = firstIndex(of: element) {
            removePointer(at: index)
        }
    }
    
    func forEach(_ body: (UnsafeMutableRawPointer?) -> Void) {
        for index in 0..<count {
            body(pointer(at: index))
        }
    }
    
    func compactForEach(_ body: (UnsafeMutableRawPointer) -> Void) {
        forEach {
            if let pointer = $0 {
                body(pointer)
            }
        }
    }
    
    func forEach<T: AnyObject>(_ objectType: T.Type, _ body: (T?) -> Void) {
        for index in 0..<count {
            if let p = pointer(at: index) {
                body(Unmanaged<T>.fromOpaque(p).takeUnretainedValue())
            } else {
                body(nil)
            }
        }
    }
    
    func compactForEach<T: AnyObject>(_ objectType: T.Type, _ body: (T) -> Void) {
        forEach(objectType) {
            if let element = $0 {
                body(element)
            }
        }
    }
    
}
