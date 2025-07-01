//
//  LockModifier.swift
//  w3w-swift-app-presenters
//
//  Created by Khai Do on 24/4/25.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftDesignSwiftUI


// hack to copy lock funtionality, the original is in
// w3w-swift-app-presenters, and it should be moved
// to w3w-swift-design.  Once it gets there, use
// that one instead and delete this one. time forbids this
// now as we are days form 5.0 launch at the moment

public extension View {
  func isLockedOcr(
    _ value: Bool,
    alignment: Alignment = .topTrailing,
    offsetX: CGFloat = 0,
    offsetY: CGFloat = 0,
    lockColor: Color = .white
  ) -> some View {
    self.cornerOverlay(
      isVisible: value,
      alignment: alignment,
      offsetX: offsetX,
      offsetY: offsetY,
      overlayView: {
        // TODO: Add lock images when ready
        W3WIconImage(
          iconImage: .w3wLock,
          iconSize: 16,
          color: lockColor
        ).padding(3)
          .background(W3WTheme.what3words.brandBase?.suColor)
          .clipShape(Circle())
      })
  }
}

