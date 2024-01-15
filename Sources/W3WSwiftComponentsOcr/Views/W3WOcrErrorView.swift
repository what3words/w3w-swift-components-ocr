//
//  W3WOcrErrorView.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftDesign

open class W3WOcrErrorView: UIView, W3WViewProtocol {
  public lazy var backgroundView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentStackView)
    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
      contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
    ])
    return view
  }()
  
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
  
  public lazy var icon: UIImageView = {
    let imageView = W3WIconView(image: .warning)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 24.0),
      imageView.widthAnchor.constraint(equalToConstant: 24.0)
    ])
    return imageView
  }()
  
  public lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  public var scheme: W3WSwiftThemes.W3WScheme?
  public var position: W3WSwiftDesign.W3WViewPosition?
  
  public func update(scheme: W3WSwiftThemes.W3WScheme?) {
    if let colors = scheme?.colors {
      titleLabel.textColor = colors.foreground?.uiColor
      titleLabel.backgroundColor = colors.line?.uiColor
      backgroundView.backgroundColor = colors.line?.uiColor
    }
    if let styles = scheme?.styles {
      titleLabel.font = styles.fonts?.originalFont
      titleLabel.textAlignment = styles.textAlignment?.value ?? .left
    }
  }
  
  public init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    addSubview(backgroundView)
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
  
  open func config(with title: String) {
    titleLabel.text = title
  }
}
