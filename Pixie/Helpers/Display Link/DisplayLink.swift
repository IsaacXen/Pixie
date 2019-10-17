import AppKit

/// Subscription-based NSTimer-liked notifier based on display refresh rate.
public class DisplayLink: NSObject {
    
    public static let shared = DisplayLink()
    
    /// The internal display link object this object managed.
    private var _displayLink: CVDisplayLink!
    
    /// Automatically stop and start display link based on subscriber count.
    ///
    /// When there's no subscriber, This object stop running displaylink. If there's at lease one subscriber, the display link will start running.
    ///
    /// Set this to `false` to disable this feature. This default value of this property is `true`.
    var autoManagedRunningState: Bool = true
    
    /// The internal weak references array to subscriber objects.
    private let _subscribers = NSPointerArray.weakObjects()
    
    private override init() {
        super.init()
        
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink)
        
        CVDisplayLinkSetOutputCallback(_displayLink, { (_, inTime, outTime, _, _, ctx) -> CVReturn in
            guard let ctx = ctx else { return kCVReturnError }
            let context = Unmanaged<DisplayLink>.fromOpaque(ctx).takeUnretainedValue()
            context.notifySubscribers(with: inTime.pointee, outputTime: outTime.pointee)
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
    }

    /// The internal display link callback function. This is the place to notify the delegate.
    private func notifySubscribers(with currentTime: CVTimeStamp, outputTime: CVTimeStamp) {
        _subscribers.compact()
        
        var iterator = NSFastEnumerationIterator(_subscribers)
        while let subscriber = iterator.next() as? DisplayLinkSubscriber {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                subscriber.displayLink(self, willOutputFrameInTime: outputTime, currentTime: currentTime)
            }
        }
    }
    
    /// Return the running status on the current display link.
    var isRunning: Bool {
        CVDisplayLinkIsRunning(_displayLink)
    }
    
    /// Start running the display link.
    ///
    /// You don't need to manually invoke this function to start the display link unless `autoManagedRunningState` is set to `false`.
    func startRunning() {
        CVDisplayLinkStart(_displayLink)
    }
    
    /// Stop running the display link.
    ///
    /// You don't need to manually invoke this function to stop the display link unless `autoManagedRunningState` is set to `false`.
    func stopRunning() {
        CVDisplayLinkStop(_displayLink)
    }
    
    private func updateRunningStateIfNeeded() {
        _subscribers.compact()
        
        if autoManagedRunningState {
            if _subscribers.count <= 0 && isRunning {
                stopRunning()
            } else if _subscribers.count > 0 && !isRunning {
                startRunning()
            }
        }
    }
    
    /// Add an object to the subscriber list to get notify when the display frame is about to output.
    ///
    /// This function does not retain the object you pass in, instead, it store a weak reference to the object. That is, you don't need to remove the object
    /// from the subscriber list if your object need to get notify for screen frame changes on its entire life cycle.
    public func addSubscriber(_ newSubscriber: DisplayLinkSubscriber) {
        _subscribers.compact()
        
        var iterator = NSFastEnumerationIterator(_subscribers)
        while let subscriber = iterator.next() as? DisplayLinkSubscriber {
            if (subscriber as? NSObject) == (newSubscriber as? NSObject) {
                return
            }
        }
        
        _subscribers.addPointer(Unmanaged.passUnretained(newSubscriber).toOpaque())
        updateRunningStateIfNeeded()
    }
    
    /// Remove an object reference from the subscriber list.
    ///
    /// In most of the case, you don't need to remove the object reference from the subscriber list, since it only keep a weak reference which will be removed
    /// automatically when needed.
    public func removeSubscriber(_ subscriber: DisplayLinkSubscriber) {
        _subscribers.compact()
        
        var index: Int = -1
        
        var iterator = NSFastEnumerationIterator(_subscribers)
        while let element = iterator.next() as? DisplayLinkSubscriber {
            index += 1
            if (element as? NSObject) == (subscriber as? NSObject) { break }
        }
        
        if index >= 0 && index < _subscribers.count {
            _subscribers.removePointer(at: index)
            updateRunningStateIfNeeded()
        }
    }
    
}
