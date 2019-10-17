import AppKit

/// An protocol confirms that an object is capable of responding to the display link update.
@objc public protocol DisplayLinkSubscriber: class {
    func displayLink(_ displayLink: DisplayLink, willOutputFrameInTime outputTime: CVTimeStamp, currentTime: CVTimeStamp)
}
