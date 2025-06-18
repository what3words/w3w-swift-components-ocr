//
//  W3WOcrStillInputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//

import CoreGraphics


public enum W3WOcrStillInputEvent {
  
  case image(CGImage?)
  case stillImage(CGImage?)
  case suggestion(W3WSuggestion)
  //case spinner(Bool)
  //case dismiss
  //case displayMode(W3WOcrViewType)
  
}
