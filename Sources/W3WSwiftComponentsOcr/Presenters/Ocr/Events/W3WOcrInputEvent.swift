//
//  W3WOcrInputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import W3WSwiftAppEvents


/// input events for ocr
public enum W3WOcrInputEvent: String, W3WAppEventConvertable {
  
  case startScanning
  case stopScanning
  
  public func asAppEvent() -> W3WAppEvent {
    return W3WAppEvent(type: Self.self, name: W3WAppEventName(value: "ocr." + self.rawValue))
  }
  
}
