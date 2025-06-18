//
//  W3WOcrStillOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//


import CoreGraphics
import W3WSwiftCore


public enum W3WOcrStillOutputEvent {
  
  case error(W3WError)
  case importImage
  case image(CGImage)
  case captureButton
  case liveCaptureSwitch(Bool)
  case footerButton(W3WSuggestionsViewAction, suggestions: [W3WSuggestion])
  case dismiss
  
}
