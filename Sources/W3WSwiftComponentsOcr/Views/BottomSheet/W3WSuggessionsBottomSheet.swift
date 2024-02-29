//
//  W3WSuggessionsBottomSheet.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 19/12/2023.
//

import UIKit
import W3WSwiftDesign
import W3WSwiftCore
import W3WSwiftThemes

open class W3WSuggessionsBottomSheet: W3WBottomSheetViewController {
  open lazy var tableViewController: W3WBottomSheetTableViewController = {
    let viewController = W3WBottomSheetTableViewController(theme: theme?.with(background: .clear))
    return viewController
  }()
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: - Public functions
  public func setState(_ state: W3WOcrState) {
    tableViewController.setState(state)
  }
  
  public func insertMoreSuggestions(_ suggestions: [W3WSuggestion]) {
    tableViewController.insertMoreSuggestions(suggestions)
  }
  
  public func moveSuggestionToFirst(_ suggestion: W3WSuggestion) {
    tableViewController.moveSuggestionToFirst(suggestion)
  }
  
  public func scrollToTop() {
    w3wView?.set(position: .bottom(height: getDetents().max()), animate: .defaultAnimationSpeed)
  }
  
  public func scrollToBottom() {
    w3wView?.set(position: .bottom(height: getDetents().min()), animate: .defaultAnimationSpeed)
  }
  
  public var isEmpty: Bool {
    return tableViewController.getItems().isEmpty
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    guard let w3wTableView = tableViewController.w3wTableView else {
      return
    }
    addChild(tableViewController)
    add(view: w3wTableView, position: .inset(by: UIEdgeInsets(top: W3WMargin.heavy.value, left: 0, bottom: 0, right: 0)))
    tableViewController.didMove(toParent: self)
    handleIndicator.set(scheme: theme?[.base])
  }
}
