//
//  W3WOcrViewController+closeButton.swift
//  
//
//  Created by Thy Nguyen on 03/01/2024.
//

import UIKit

extension W3WOcrViewController {
  public func addCloseButton() {
    guard isPresentedModally() else {
      return
    }
    view.addSubview(closeButton)
    NSLayoutConstraint.activate([
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ])
  }
  
  @objc public func didTouchCloseButton() {
    presentingViewController?.dismiss(animated: true)
  }
}
