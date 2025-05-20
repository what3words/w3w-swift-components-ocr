//
//  W3WOcrInputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import CoreGraphics


public enum W3WOcrInputEvent {
  
  case image(CGImage?)
  case stillImage(CGImage?)
  case suggestion(W3WSuggestion)
  //case spinner(Bool)
  //case dismiss
  //case displayMode(W3WOcrViewType)
  
}
