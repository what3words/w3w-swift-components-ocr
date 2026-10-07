//
//  UIView+OcrAccessibilityId.swift
//  w3w-swift-components-ocr
//
//  Copyright © 2026 What3Words. All rights reserved.
//

#if canImport(UIKit)
import UIKit


extension UIView {

  /// Sets `id` as the accessibility identifier; keeps any existing identifier when `id` is nil.
  func ocrAccessibilityId(_ id: String?) {
    guard let id else { return }
    accessibilityIdentifier = id
  }
}
#endif
