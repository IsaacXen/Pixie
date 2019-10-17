import Foundation

protocol DefaultsControllerSubscriber: AnyObject {
    func defaultsController(_ controller: DefaultsController, didChangeDefaultWithKeyPath keyPath: String)
}
