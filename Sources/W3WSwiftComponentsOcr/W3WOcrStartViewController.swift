//
//  W3WOcrStartViewController.swift
//
//
//  Created by Thy Nguyen on 12/01/2024.
//

import UIKit
import W3WSwiftDesign
import W3WSwiftCore

open class W3WOcrStartViewController: W3WViewController {
  public var ocr: W3WOcrProtocol?
  public var w3w: W3WProtocolV4?
  
  public init(ocr: W3WOcrProtocol, w3w: W3WProtocolV4? = nil) {
    self.ocr = ocr
    self.w3w = w3w
    super.init(theme: nil)
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - UI properties
  open lazy var bgView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundImageView)
    view.addSubview(blurView)
    NSLayoutConstraint.activate([
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      blurView.topAnchor.constraint(equalTo: view.topAnchor),
      blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    return view
  }()
  
  open lazy var backgroundImageView: UIImageView = {
    let view = W3WIconView(image: .w3wBackground)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  open lazy var blurView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = W3WColor.labelColourLight.uiColor
    return view
  }()
  
  open lazy var contentStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [startButton, startScanningLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.alignment = .center
    view.spacing = W3WMargin.heavy.value
    return view
  }()
  
  open lazy var startButton: W3WButton = {
    let button = W3WButton(image: .w3wIcon) { [weak self] in
      self?.didTapStartScanning()
    }
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: 64),
      button.widthAnchor.constraint(equalToConstant: 64)
    ])
    return button
  }()
  
  private lazy var startScanningLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  open func setup() {
    W3WTranslations.main.add(bundle: Bundle.module)
    setupUI()
  }
  
  open func setupUI() {
    view.addSubview(bgView)
    view.addSubview(contentStackView)
    NSLayoutConstraint.activate([
      bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bgView.topAnchor.constraint(equalTo: view.topAnchor),
      bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    update(scheme: theme?[.base])
    setTitle(W3WTranslations.main.translate(key: "Start scanning"))
  }
  
  open func update(scheme: W3WScheme?) {
    startScanningLabel.font = scheme?.styles?.fonts?.originalFont
    startScanningLabel.textColor = scheme?.colors?.foreground?.uiColor
  }
  
  public func setTitle(_ text: String) {
    startScanningLabel.text = text
  }
  
  open func didTapStartScanning() {
    guard let ocr = ocr else {
      return
    }
    let viewController = W3WOcrViewController(ocr: ocr, w3w: w3w)
    viewController.start()
    show(viewController, sender: nil)
  }
}
