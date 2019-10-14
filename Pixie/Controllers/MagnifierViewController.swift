import Cocoa
import AVFoundation

class MagnifierViewController: NSViewController {

    override func loadView() {
        let v = NSVisualEffectView(frame: NSMakeRect(0, 0, 300, 300))
        v.material = .sidebar
        v.state = .active
        v.blendingMode = .behindWindow
        view = v
    }
    
    let imageView: MagnifierView = {
        let view = MagnifierView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
        
    override func viewDidLoad() {
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillAppear() {
        imageView.resumeLinking()
    }
    
    
}

