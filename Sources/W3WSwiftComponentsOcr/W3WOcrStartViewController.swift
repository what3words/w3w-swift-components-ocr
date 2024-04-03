//
//  W3WOcrStartViewController.swift
//
//
//  Created by Thy Nguyen on 12/01/2024.
//

#if canImport(UIKit)
import UIKit
import W3WSwiftDesign
import W3WSwiftCore

open class W3WOcrStartViewController: W3WViewController {
  private var ocr: W3WOcrProtocol?
  private var w3w: W3WProtocolV4?

  public init(ocr: W3WOcrProtocol, w3w: W3WProtocolV4? = nil, theme: W3WTheme? = .standard) {
    self.ocr = ocr
    self.w3w = w3w
    super.init(theme: theme)
    set(theme: theme)
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  // MARK: - UI properties
  open lazy var contentStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [startButton, startScanningLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.alignment = .center
    view.spacing = W3WMargin.heavy.value
    return view
  }()

  open lazy var startButton: W3WButton = {
    let button = W3WButton(image: .w3wLogo) { [weak self] in
      self?.didTapStartScanning()
    }
    button.imageView?.contentMode = .scaleAspectFit
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: W3WIconSize.largeIcon.value.height),
      button.widthAnchor.constraint(equalToConstant: W3WIconSize.largeIcon.value.width)
    ])
    return button
  }()

  open lazy var startScanningLabel: W3WLabel = {
    let label = W3WLabel(fontStyle: .title2)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = W3WTranslations.main.translate(key: "Start scanning")
    label.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStartScanning))
    label.addGestureRecognizer(tap)
    return label
  }()

  // MARK: - Setup
  open func setup() {
    W3WTranslations.main.add(bundle: Bundle.main)
    setupUI()
  }

  open func setupUI() {
    view.addSubview(contentStackView)
    NSLayoutConstraint.activate([
      contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  // MARK: - Actions
  @objc open func didTapStartScanning() {
    guard let ocr = ocr else {
      return
    }
    let viewController = W3WOcrViewController(ocr: ocr, theme: theme, w3w: w3w)
    viewController.start()
    show(viewController, sender: nil)
  }
  
  // MARK: - W3WViewController overrides
  open override func set(theme: W3WTheme?) {
    super.set(theme: theme)
    startScanningLabel.set(scheme: theme?[.base]?.with(background: .clear))
    startButton.set(scheme: theme?[.base]?.with(background: .clear).with(foreground: .standardBrandBase))
  }
}
#endif
