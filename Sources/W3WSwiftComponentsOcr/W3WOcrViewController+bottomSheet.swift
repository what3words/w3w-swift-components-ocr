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
  /**
  Min detent of bottom sheet
   
  When there's no scanned results, will be state row estimated height (56.0) + extra space for bottom safe area.
   
  When there's scanned results, will be state row estimated height + maximum 1.5 row height of scanned result.
  */
  var minDetent: CGFloat {
    var minDetent = 56.0 + max(W3WMargin.bold.value, view.safeAreaInsets.bottom)
    if !bottomSheet.tableViewController.getItems().isEmpty {
      minDetent = 56.0 + bottomSheet.tableViewController.rowHeight * min(1.5, CGFloat(bottomSheet.tableViewController.getItems().count))
    }
    return minDetent
  }
  
  /**
  Max detent of bottom sheet
   
  Is equal to total height of all scanned result rows and maximum is the remaining space on screen minus the margin
  */
  var maxDetent: CGFloat {
    let contentHeight = 56.0 + CGFloat(bottomSheet.tableViewController.getItems().count) * bottomSheet.tableViewController.rowHeight + view.safeAreaInsets.bottom
    let maxHeight = view.bounds.height - (ocrView.crop.origin.y + ocrView.crop.height + W3WMargin.heavy.value)
    return min(contentHeight, maxHeight)
  }
  
  /// Add or update bottom sheet with min and max detents. Add bottom sheet to current viewController at min detent if needed.
  public func updateBottomSheet() {
    let detents = [minDetent, maxDetent]
    guard bottomSheet.getDetents() != detents else {
      return
    }
    bottomSheet.removeDetents()
    bottomSheet.add(detents: detents)
    if bottomSheet.w3wView?.superview == nil {
      add(viewController: bottomSheet, position: .bottom(height: bottomSheet.getDetents().first))
    }
  }
  
  /// Insert more auto suggestions on bottom sheet  under the crop, scroll bottom sheet to max detent and hide error view
  /// - Parameters:
  ///     - suggestion: the suggestion that was found
  public func insertMoreSuggestions(_ suggestions: [W3WSuggestion]) {
    guard !suggestions.isEmpty else {
      return
    }
    if !errorView.isHidden {
      hideErrorView()
    }
    bottomSheet.insertMoreSuggestions(suggestions)
    updateBottomSheet()
    bottomSheet.scrollToTop()
  }
  
  public func moveSuggestionToFirst(_ suggestion: W3WSuggestion) {
    bottomSheet.moveSuggestionToFirst(suggestion)
  }
}
