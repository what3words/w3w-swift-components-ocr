//
//  W3WSingleLabelTableViewCell.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftDesign

public class W3WSingleLabelTableViewCell: W3WTableViewCell, W3WViewManagerProtocol {
  public var parentView: UIView?
  public var managedViews: [W3WSwiftDesign.W3WViewProtocol] = []
  
  public lazy var titleLabel: W3WLabel = {
    let label = W3WLabel(fontStyle: .headline)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    scheme = .standard.with(background: .clear)
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
    scheme = .standard
    update(scheme: .standard)
  }
  
  open func configure(with item: W3WSingleLabelCellItem?) {
    // Update cell UI
    scheme = item?.scheme
    update(scheme: item?.scheme)
    
    // Update label UI
    titleLabel.scheme = item?.scheme
    titleLabel.update(scheme: item?.scheme)
    titleLabel.text = item?.text
  }
  
  // MARK: - W3WTableViewCell overrides
  public override func update(scheme: W3WScheme?) {
    backgroundColor = scheme?.colors?.background?.current.uiColor
    contentView.backgroundColor = scheme?.colors?.background?.current.uiColor
  }
}
