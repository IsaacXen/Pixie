import Foundation

/// Clamping a `Comparable` value from a lower bound up to, and including, an upper bound.
@propertyWrapper
struct Floored<Value: FloatingPoint> {
    
    var value: Value
    let nearest: Value
    
    var wrappedValue: Value {
        get { floor(value / nearest) * nearest }
        set { value = newValue }
    }
    
    init(wrappedValue: Value, nearest: Value) {
        precondition(nearest > 0, "`nearest` must be a floating point value greater than 0.")
        self.value = wrappedValue
        self.nearest = nearest
    }
    
}
