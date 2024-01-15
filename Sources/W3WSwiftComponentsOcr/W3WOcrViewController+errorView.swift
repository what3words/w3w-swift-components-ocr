//
//  W3WOcrViewController+error.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftDesign

extension W3WOcrViewController {
  public func setupErrorView() {
    guard ocrView.crop != .zero else {
      return
    }
    if errorView.superview != nil {
      errorView.removeFromSuperview()
    }
    errorView.update(scheme: theme?.getOcrScheme(state: .error))
    view.addSubview(errorView)
    NSLayoutConstraint.activate([
      errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: W3WMargin.light.value),
      errorView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -W3WMargin.light.value),
      errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ocrView.crop.origin.y + ocrView.crop.height + W3WMargin.heavy.value)
    ])
  }
  
  public func showErrorView(title: String) {
    errorView.config(with: title)
    UIView.animate(withDuration: 0.4) {
      self.errorView.isHidden = false
    }
    bottomSheet.scrollToBottom()
  }
  
  public func hideErrorView() {
    UIView.animate(withDuration: 0.4) {
      self.errorView.isHidden = true
    }
  }
}