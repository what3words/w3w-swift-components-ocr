//
//  W3WOcrOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import W3WSwiftCore


public enum W3WOcrOutputEvent {
  
  case error(W3WError)
  case detected(W3WSuggestion)
  case importImage
  
}
