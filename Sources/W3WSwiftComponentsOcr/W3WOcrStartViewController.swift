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
  open lazy var w3wLogo: W3WIconView = {
    let imageView = W3WIconView(image: .w3wLogoWithColorMode)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 24.0),
    ])
    return imageView
  }()

  open lazy var startButton: W3WButton = {
    let button = W3WButton(label: W3WTranslations.main.translate(key: "Start scanning"), fontStyle: .body) { [weak self] in
      self?.didTapStartScanning()
    }
    button.imageView?.contentMode = .scaleAspectFit
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: 52.0),
    ])
    return button
  }()

  // MARK: - Setup
  open func setup() {
    W3WTranslations.main.add(bundle: Bundle.module)
    setupUI()
  }

  open func setupUI() {
    view.addSubview(w3wLogo)
    view.addSubview(startButton)
    NSLayoutConstraint.activate([
      w3wLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      w3wLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: W3WMargin.bold.value),
      startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -W3WMargin.heavy.value)
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
    startButton.set(scheme: theme?[.base]?
      .with(fonts: W3WFonts().with(body: .semibold))
      .with(background: theme?[.base]?.colors?.tint)
      .with(foreground: .white)
      .with(cornerRadius: .soft))
  }
}
