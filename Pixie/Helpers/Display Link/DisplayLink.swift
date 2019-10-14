import AppKit

public class DisplayLink: NSObject {
    
    public static let shared = DisplayLink()
    
    private var _displayLink: CVDisplayLink!
    
    var autoManagedRunningState: Bool = true
    
    private var _subscribers = WeakArray<DisplayLinkSubscriber>()
    
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
        _subscribers.forEach { [weak self] subscriber in
            guard let self = self else { return }
            DispatchQueue.main.async {
                subscriber?.displayLink(self, willOutputFrameInTime: outputTime, currentTime: currentTime)
            }
        }
    }
    
    var isRunning: Bool {
        CVDisplayLinkIsRunning(_displayLink)
    }
    
    func startRunning() {
        CVDisplayLinkStart(_displayLink)
    }
    
    func stopRunning() {
        CVDisplayLinkStop(_displayLink)
    }
    
    private func updateRunningStateIfNeeded() {
        if autoManagedRunningState {
            if _subscribers.isCompactEmpty && isRunning {
                stopRunning()
            } else if !_subscribers.isCompactEmpty && !isRunning {
                startRunning()
            }
        }
        print(#function, isRunning)
    }
    
    public func addSubscriber(_ subscriber: DisplayLinkSubscriber) {
        _subscribers.append(subscriber)
        updateRunningStateIfNeeded()
    }
    
    public func removeSubscriber(_ subscriber: DisplayLinkSubscriber) {
        if let index = _subscribers.firstIndex(where: {
            guard let lhs = $0 as? NSObject, let rhs = subscriber as? NSObject else { return false }
            return lhs == rhs
        }) {
            _subscribers.remove(at: index)
        }
        updateRunningStateIfNeeded()
    }
    
}
