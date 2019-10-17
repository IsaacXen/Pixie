import Foundation

struct Default<T>: Equatable {
    
    let keyPath: String
    let defaultValue: T
    let readOnly: Bool
    
    init(_ keyPath: String, _ defaultValue: T, readOnly: Bool = false) {
        self.keyPath = keyPath
        self.defaultValue = defaultValue
        self.readOnly = readOnly
    }

    static func == (lhs: Default<T>, rhs: Default<T>) -> Bool {
        lhs.keyPath == rhs.keyPath
    }
    
}
