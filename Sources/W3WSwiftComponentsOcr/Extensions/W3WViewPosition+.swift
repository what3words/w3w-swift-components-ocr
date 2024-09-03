//
//  File.swift
//  
//
//  Created by Dave Duprey on 21/05/2024.
//

import UIKit
import W3WSwiftDesign


extension W3WViewPosition {

  static func bottomButton(width: CGFloat? = nil, height: CGFloat = 52.0, insetBy: CGFloat = 16.0) -> W3WViewPosition {
    return W3WViewPosition() { parent, this in
      return CGRect(
        x: (parent?.safeAreaInsets.right ?? 0.0) + insetBy,
        y: (parent?.frame.height ?? 0.0) - (parent?.safeAreaInsets.bottom ?? 0.0)  - insetBy - height,
        width: width ?? (parent?.frame.width ?? 0.0) - (parent?.safeAreaInsets.left ?? 0.0) - (parent?.safeAreaInsets.right ?? 0.0) - insetBy * 2.0,
        height: height
      )
    }
  }

}
