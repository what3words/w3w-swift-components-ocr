//
//  W3WOcrErrorView.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

#if canImport(UIKit)
import UIKit
import W3WSwiftDesign

open class W3WOcrErrorView: UIView, W3WViewProtocol {
  public lazy var backgroundView: W3WView = {
    let view = W3WView()
    view.translatesAutoresizingMaskIntoConstraints = false
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
  
  public var scheme: W3WSwiftThemes.W3WScheme?
  public var position: W3WSwiftDesign.W3WViewPosition?
  
  public func update(scheme: W3WSwiftThemes.W3WScheme?) {
    icon.set(scheme: scheme?.with(background: .clear))
    titleLabel.set(scheme: scheme?.with(background: .clear))
    backgroundView.set(scheme: scheme?.with(background: scheme?.colors?.line))
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
    addSubview(contentStackView)
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
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
#endif
