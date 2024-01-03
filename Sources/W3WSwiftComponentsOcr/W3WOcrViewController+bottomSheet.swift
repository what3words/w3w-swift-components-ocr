//
//  W3WOcrViewController+bottomSheet.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 19/12/2023.
//

import UIKit
import W3WSwiftDesign
import W3WSwiftCore

extension W3WOcrViewController {
  /// Min detent of bottom sheet
  /// When there's no search results, will be state row estimated height (56.0) + extra space for bottom safe area
  /// When there's search results, will be state row estimated height + height of 1.5 rows of search result
  var minDetent: CGFloat {
    var minDetent = 56.0 + max(W3WMargin.bold.value, view.safeAreaInsets.bottom)
    if !bottomSheet.tableViewController.getItems().isEmpty {
      minDetent = 56.0 + bottomSheet.tableViewController.rowHeight * 1.5
    }
    return minDetent
  }
  
  /// Add or update bottom sheet with min and max detents
  public func updateBottomSheet() {
    let maxDetent = view.bounds.height - (ocrView.crop.origin.y + ocrView.crop.height + W3WSettings.ocrCropInset)
    let detents = [minDetent, maxDetent]
    guard bottomSheet.getDetents() != detents else {
      return
    }
    bottomSheet.removeDetents()
    bottomSheet.add(detents: detents)
    if bottomSheet.w3wView?.superview == nil {
      add(viewController: bottomSheet, position: .bottom(height: bottomSheet.getDetents().first))
    } else {
      bottomSheet.w3wView?.set(position: .bottom(height: bottomSheet.getDetents().first))
    }
  }
  
  /// Insert more auto suggestions on bottom sheet  under the crop, scroll bottom sheet to max detent and hide error view
  /// - Parameters:
  ///     - suggestion: the suggestion that was found
  public func insertMoreAutoSuggestions(_ suggestions: [W3WSuggestion]) {
    guard !suggestions.isEmpty else {
      return
    }
    var shouldScrollUp = false
    if bottomSheet.tableViewController.getItems().isEmpty {
      shouldScrollUp = true
    }
    if !errorView.isHidden {
      hideErrorView()
      shouldScrollUp = true
    }
    bottomSheet.insertMoreSuggestions(suggestions)
    if shouldScrollUp {
      updateBottomSheet()
      bottomSheet.scrollToTop()
    }
  }
}
