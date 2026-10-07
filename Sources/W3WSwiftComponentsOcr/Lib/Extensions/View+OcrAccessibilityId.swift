//
//  View+OcrAccessibilityId.swift
//  w3w-swift-components-ocr
//
//  Copyright © 2026 What3Words. All rights reserved.
//

import SwiftUI


extension View {

  /// Sets `id` as the accessibility identifier; leaves the view untouched when `id` is nil.
  @ViewBuilder
  func ocrAccessibilityId(_ id: String?) -> some View {
    if let id {
      accessibilityIdentifier(id)
    } else {
      self
    }
  }

  /// For views that contain other tagged views: SwiftUI pushes an identifier down to every
  /// descendant and the outermost one wins, so the container must keep its children separate.
  @ViewBuilder
  func ocrAccessibilityContainerId(_ id: String?) -> some View {
    if let id {
      accessibilityElement(children: .contain)
        .accessibilityIdentifier(id)
    } else {
      self
    }
  }
}
