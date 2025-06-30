//
//  W3WOcrStillInputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//

import CoreGraphics
import W3WSwiftAppEvents


/// input events for still image ocr
public enum W3WOcrStillInputEvent: W3WAppEventConvertable {
  
  /// send an image in
  case image(CGImage?)

  
  public func asAppEvent() -> W3WAppEvent {
    switch self {
      case .image(let image):
        return W3WAppEvent(type: Self.self, name: "ocr.still.image", parameters: ["resolution": .text("\(image?.width ?? Int(0.0)),\(image?.height ?? Int(0.0))")])
    }
  }

}
