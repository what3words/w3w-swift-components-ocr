//
//  W3WImagePickerOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 06/05/2025.
//

import CoreGraphics


public enum W3WImagePickerOutputEvent {
  
  case image(CGImage)
  case dismiss
  case error(W3WError)
  
}
