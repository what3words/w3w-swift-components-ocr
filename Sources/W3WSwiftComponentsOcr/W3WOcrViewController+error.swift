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
    guard ocrView.crop != .zero, errorView.superview == nil else {
      return
    }
    errorView.update(scheme: theme?.getOcrScheme(state: .error))
    view.addSubview(errorView)
    NSLayoutConstraint.activate([
      errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: W3WMargin.light.value),
      errorView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: W3WMargin.bold.value + ocrView.crop.height + ocrView.crop.origin.x)
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
