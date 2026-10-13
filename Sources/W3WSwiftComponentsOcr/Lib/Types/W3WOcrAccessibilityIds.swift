//
//  W3WOcrAccessibilityIds.swift
//  w3w-swift-components-ocr
//
//  Copyright © 2026 What3Words. All rights reserved.
//

import Foundation


/// Accessibility identifiers the OCR views apply, for UI automation.
/// Every field is optional: an element whose id is nil gets no identifier.
public struct W3WOcrAccessibilityIds {
  public var root: String?
  public var backButton: String?
  public var viewfinder: String?
  public var liveScanToggle: String?
  /// used instead of `liveScanToggle` while live scan is locked
  public var liveScanLock: String?
  public var importButton: String?
  /// used instead of `importButton` while import is locked
  public var importButtonLock: String?
  public var resultsList: String?
  /// id for the result row at the given index
  public var resultsListRow: ((Int) -> String)?

  public init(root: String? = nil,
              backButton: String? = nil,
              viewfinder: String? = nil,
              liveScanToggle: String? = nil,
              liveScanLock: String? = nil,
              importButton: String? = nil,
              importButtonLock: String? = nil,
              resultsList: String? = nil,
              resultsListRow: ((Int) -> String)? = nil) {
    self.root = root
    self.backButton = backButton
    self.viewfinder = viewfinder
    self.liveScanToggle = liveScanToggle
    self.liveScanLock = liveScanLock
    self.importButton = importButton
    self.importButtonLock = importButtonLock
    self.resultsList = resultsList
    self.resultsListRow = resultsListRow
  }
}
