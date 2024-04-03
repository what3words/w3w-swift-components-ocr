//
//  W3WSingleLabelTableViewCell.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

#if canImport(UIKit)
import UIKit
import W3WSwiftDesign

public class W3WSingleLabelTableViewCell: W3WTableViewCell {
  public lazy var titleLabel: W3WLabel = {
    let label = W3WLabel(fontStyle: .headline)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    makeUI()
  }
  
  override public init(scheme: W3WScheme? = nil) {
    super.init(style: .default, reuseIdentifier: Self.cellIdentifier)
    self.scheme = scheme
    makeUI()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    makeUI()
  }
  
  open func makeUI() {
    contentView.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: W3WMargin.light.value),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -W3WMargin.medium.value),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: W3WMargin.bold.value),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -W3WMargin.bold.value)
    ])
    // Set default scheme
    set(scheme: .standard.with(background: .clear))
  }
  
  open func configure(with item: W3WSingleLabelCellItem?) {
    set(scheme: item?.scheme)
    titleLabel.text = item?.text
  }
  
  // MARK: - W3WTableViewCell overrides
  public override func set(scheme: W3WScheme?) {
    self.scheme = scheme
    update(scheme: scheme)
    titleLabel.scheme = scheme
    titleLabel.update(scheme: scheme)
  }
  
  public override func update(scheme: W3WScheme?) {
    backgroundColor = scheme?.colors?.background?.current.uiColor
    contentView.backgroundColor = scheme?.colors?.background?.current.uiColor
  }
}
#endif
