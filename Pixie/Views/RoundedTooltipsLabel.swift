import Cocoa

class RoundedTooltipsLabel: NSView {
    
    // MARK: - Public Configurable
    
    var edgeInset: NSEdgeInsets = NSEdgeInsetsMake(3, 2, 3, 2) {
        didSet {
            _visualBackground.constraints.filter {
                $0.firstItem?.isEqual(_label) ?? false && $0.secondItem?.isEqual(_visualBackground) ?? false && $0.firstAttribute == $0.secondAttribute
            }.forEach {
                switch $0.firstAttribute {
                    case      .top: $0.constant = edgeInset.top
                    case  .leading: $0.constant = edgeInset.left
                    case .trailing: $0.constant = -edgeInset.right
                    case   .bottom: $0.constant = -edgeInset.bottom
                    default: ()
                }
            }
        }
    }
    
    var cornerRadius: CGFloat = 5 {
        didSet {
            _visualBackground.maskImage = NSImage(size: NSMakeSize(cornerRadius * 2, cornerRadius * 2), flipped: false, drawingHandler: {
                NSColor.black.setFill()
                NSBezierPath(roundedRect: $0, xRadius: $0.width / 2, yRadius: $0.height / 2).fill()
                return true
            })
            _visualBackground.maskImage?.capInsets = NSEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
        }
    }
    
    var stringValue: String = "Label" {
        didSet {
            _label.stringValue = stringValue
        }
    }
    
    // MARK: - Subviews
    
    lazy var _visualBackground: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.material = .toolTip
        view.blendingMode = .withinWindow
        view.state = .active
        view.maskImage = NSImage(size: NSMakeSize(cornerRadius * 2, cornerRadius * 2), flipped: false, drawingHandler: {
            NSColor.black.setFill()
            NSBezierPath(roundedRect: $0, xRadius: $0.width / 2, yRadius: $0.height / 2).fill()
            return true
        })
        view.maskImage?.capInsets = NSEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var _label: NSTextField = {
        let view = NSTextField()
        view.isEditable = false
        view.isSelectable = false
        view.isBordered = false
        view.lineBreakMode = .byTruncatingTail
        view.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .semibold)
        view.textColor = NSColor.textColor
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Setup Subviews
    
    private func _setupSubViews() {
        addSubview(_visualBackground)
        _visualBackground.addSubview(_label)
        
        _setupConstraints()
    }
    
    private func _setupConstraints() {
        NSLayoutConstraint.activate([
            _visualBackground.topAnchor.constraint(equalTo: topAnchor),
            _visualBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            _visualBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            _visualBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            _label.topAnchor.constraint(equalTo: _visualBackground.topAnchor, constant: edgeInset.top),
            _label.leadingAnchor.constraint(equalTo: _visualBackground.leadingAnchor, constant: edgeInset.left),
            _label.trailingAnchor.constraint(equalTo: _visualBackground.trailingAnchor, constant: -edgeInset.right),
            _label.bottomAnchor.constraint(equalTo: _visualBackground.bottomAnchor, constant: -edgeInset.bottom),
        ])
    }
    
    // MARK: -
    
    private func _viewDidLoad() {
        _setupSubViews()
    }
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _viewDidLoad()
    }
    
}
