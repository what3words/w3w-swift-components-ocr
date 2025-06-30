//
//  W3WSuOcrView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import UIKit
import SwiftUI
import W3WSwiftThemes


/// Holds a UIKit W3WOcrView in a SwiftUI view
struct W3WSuOcrView: UIViewRepresentable {
  
  let ocrView: W3WOcrView
  

  /// Holds a UIKit W3WOcrView in a SwiftUI view
  /// - Parameters:
  ///     - ocrView: the UIView derived W3WOcrView to embed
  public init(ocrView: W3WOcrView) {
    self.ocrView = ocrView
  }
  
  
  func makeUIView(context: Context) -> W3WOcrView {
    return ocrView
  }
  
  
  func updateUIView(_ uiView: W3WOcrView, context: Context) {
  }
  
}
