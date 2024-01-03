//
//  W3WSingleLabelTableViewCell.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftDesign

public class W3WSingleLabelTableViewCell: UITableViewCell {
  public static var cellIdentifier: String { get { return String(describing: Self.self) } }
  
  public lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    makeUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func makeUI() {
    contentView.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: W3WMargin.light.value),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -W3WMargin.medium.value),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: W3WMargin.bold.value),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -W3WMargin.bold.value)
    ])
  }
  
  open func configure(with item: W3WSingleLabelCellItem?) {
    titleLabel.text = item?.text
    if let colors = item?.scheme?.colors {
      titleLabel.textColor = colors.foreground?.uiColor
      titleLabel.backgroundColor = colors.background?.uiColor
      contentView.backgroundColor = colors.background?.uiColor
    }
    if let styles = item?.scheme?.styles {
      titleLabel.font = styles.fonts?.originalFont
      titleLabel.textAlignment = styles.textAlignment?.value ?? .left
    }
  }
}
