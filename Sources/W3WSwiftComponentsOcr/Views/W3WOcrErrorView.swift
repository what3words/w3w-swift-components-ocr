//
//  W3WOcrErrorView.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftDesign

open class W3WOcrErrorView: W3WView {
  public lazy var contentStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [icon, titleLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.spacing = W3WMargin.bold.value
    view.isLayoutMarginsRelativeArrangement = true
    view.layoutMargins = W3WPadding.medium.insets
    return view
  }()
  
  public lazy var icon: W3WIconView = {
    let imageView = W3WIconView(image: .warning)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 24.0),
      imageView.widthAnchor.constraint(equalToConstant: 24.0)
    ])
    return imageView
  }()
  
  public lazy var titleLabel: W3WLabel = {
    let label = W3WLabel(fontStyle: .caption1)
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  public func set(scheme: W3WScheme?) {
    self.scheme = scheme?.with(background: scheme?.colors?.error?.background)
    icon.set(scheme: scheme?.with(background: .clear).with(foreground: scheme?.colors?.error?.foreground))
    titleLabel.set(scheme: scheme?.with(background: .clear).with(foreground: scheme?.colors?.error?.foreground))
  }
  
  override init(scheme: W3WScheme? = nil) {
    super.init(scheme: scheme)
    setupUI()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentStackView)
    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(equalTo: topAnchor),
      contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    ])
  }
  
  open func config(with title: String) {
    titleLabel.text = title
  }
}
