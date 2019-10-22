import Foundation

/// Clamping a `Comparable` value from a lower bound up to, and including, an upper bound.
@propertyWrapper
struct Clamping<Value: Comparable> {
    
    var value: Value
    let range: ClosedRange<Value>
    
    var wrappedValue: Value {
        get { value }
        set { value = max(range.lowerBound, min(newValue, range.upperBound)) }
    }
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.value = max(range.lowerBound, min(wrappedValue, range.upperBound))
        self.range = range
    }
    
}
