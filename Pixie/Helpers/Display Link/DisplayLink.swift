import AppKit

public class DisplayLink: NSObject {
    
    public static let shared = DisplayLink()
    
    private var _displayLink: CVDisplayLink!
    
    var autoManagedRunningState: Bool = true
    
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
    
    var isRunning: Bool {
        CVDisplayLinkIsRunning(_displayLink)
    }
    
    func startRunning() {
        CVDisplayLinkStart(_displayLink)
        print("DisplayLink Started")
    }
    
    func stopRunning() {
        CVDisplayLinkStop(_displayLink)
        print("DisplayLink Stopped")
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

extension NSPointerArray {

    func add(_ newElement: AnyObject) {
        addPointer(Unmanaged.passUnretained(newElement).toOpaque())
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
