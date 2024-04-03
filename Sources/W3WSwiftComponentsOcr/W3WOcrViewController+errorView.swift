//
//  W3WOcrViewController+error.swift
//
//
//  Created by Thy Nguyen on 20/12/2023.
//

#if canImport(UIKit)
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
#endif
