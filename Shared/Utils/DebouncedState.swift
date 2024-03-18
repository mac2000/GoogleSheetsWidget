import Foundation

public class DebouncedState<Value>: ObservableObject {
    @Published public var currentValue: Value
    @Published public var debouncedValue: Value
    
    public init(initialValue: Value, delay: Double = 0.3) {
        _currentValue = Published(initialValue: initialValue)
        _debouncedValue = Published(initialValue: initialValue)
        $currentValue
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedValue)
    }
}
