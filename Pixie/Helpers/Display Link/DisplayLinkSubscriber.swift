import AppKit

@objc public protocol DisplayLinkSubscriber: class {
    func displayLink(_ displayLink: DisplayLink, willOutputFrameInTime outputTime: CVTimeStamp, currentTime: CVTimeStamp)
}
