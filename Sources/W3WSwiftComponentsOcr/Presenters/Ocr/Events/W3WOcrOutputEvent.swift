//
//  W3WOcrOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import CoreGraphics
import W3WSwiftCore


public enum W3WOcrOutputEvent {
  
  case error(W3WError)
  case importImage
  case image(CGImage)
  case captureButton
  case liveCaptureSwitch(Bool)
  case footerButton(W3WSuggestionsViewControllerFactory, suggestions: [W3WSuggestion])
}
