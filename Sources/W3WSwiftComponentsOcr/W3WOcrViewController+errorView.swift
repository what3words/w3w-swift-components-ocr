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
    let errorScheme = theme?.getOcrScheme(state: .error)
    errorView.set(scheme: errorScheme)
    view.addSubview(errorView)
    NSLayoutConstraint.activate([
      errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: W3WMargin.bold.value),
      errorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -W3WMargin.bold.value),
      errorView.topAnchor.constraint(equalTo: view.topAnchor, constant: ocrView.crop.origin.y + ocrView.crop.height + W3WMargin.heavy.value)
    ])
  }
  
  public func showErrorView(title: String) {
    guard errorView.isHidden == true else {
      return
    }
    errorView.config(with: title)
    errorView.isHidden = false
    errorView.layoutIfNeeded()
    // Update bottom sheet position
    setupBottomSheet()
    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut) {
      self.errorView.alpha = 1.0
    }
  }
  
  public func hideErrorView() {
    guard errorView.isHidden == false else {
      return
    }
    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut) {
      self.errorView.alpha = 0.0
    } completion: { _ in
      self.errorView.isHidden = true
      // Update bottom sheet position
      self.setupBottomSheet()
    }
  }
}
