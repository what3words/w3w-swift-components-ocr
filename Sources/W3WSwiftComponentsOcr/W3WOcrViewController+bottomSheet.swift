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
   Bottom sheet header estimated height
   
   This value is equal to estimated height of state row + dragging area height.
   */
  public var headerEstimatedHeight: CGFloat {
    let stateRowEstimatedHeight = 34.0
    return stateRowEstimatedHeight + W3WMargin.heavy.value
  }
  
  /**
   Min detent of bottom sheet
   
   When there are no scanned results, this value is equal to header estimated height + extra space for bottom margin.
   
   When there are scanned results, it is equal to header estimated height + maximum 1.5 row height of scanned result.
   */
  var minDetent: CGFloat {
    var minDetent = headerEstimatedHeight + max(W3WMargin.medium.value, W3WSettings.bottomSafeArea)
    if !bottomSheet.tableViewController.getItems().isEmpty {
      minDetent = headerEstimatedHeight + bottomSheet.tableViewController.rowHeight * min(1.5, CGFloat(currentItemsCount))
    }
    return minDetent
  }
  
  /**
   Max detent of bottom sheet
   
   This value is equal to header estimated height + total height of all scanned result rows + safe area bottom space, maximum is the remaining space on screen subtracted by the margin.
   */
  var maxDetent: CGFloat? {
    guard view.bounds.height != 0 else {
      return nil
    }
    let crop = ocrView.crop
    let contentHeight = headerEstimatedHeight + CGFloat(currentItemsCount) * bottomSheet.tableViewController.rowHeight + W3WSettings.bottomSafeArea
    let errorViewHeight = errorView.isHidden ? 0.0 : (errorView.bounds.height + W3WMargin.medium.value)
    let maxHeight = view.bounds.height - (crop.origin.y + crop.height + W3WMargin.heavy.value + errorViewHeight)
    return min(contentHeight, maxHeight)
  }
  
  /// Add or update bottom sheet with min and max detents. Add bottom sheet to current viewController at min detent if needed.
  public func setupBottomSheet() {
    var detents = [minDetent]
    if let max = maxDetent, let tempMin = detents.first {
      detents = [min(tempMin, max), max]
    }
    guard bottomSheet.getDetents() != detents else {
      return
    }
    bottomSheet.removeDetents()
    bottomSheet.add(detents: detents)
    if bottomSheet.w3wView?.superview == nil {
      add(viewController: bottomSheet, position: .bottom(height: bottomSheet.getDetents().first))
    } else {
      if bottomSheet.tableViewController.getItems().isEmpty {
        bottomSheet.scrollToBottom(animate: false)
      } else {
        bottomSheet.scrollToTop()
      }
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
    setupBottomSheet()
    bottomSheet.scrollToTop()
  }
  
  /// Move existing suggestion in the list to top
  public func moveSuggestionToFirst(_ suggestion: W3WSuggestion) {
    bottomSheet.moveSuggestionToFirst(suggestion)
  }
  
  /// Current items count
  private var currentItemsCount: Int {
    return bottomSheet.tableViewController.getItems().count
  }
}
