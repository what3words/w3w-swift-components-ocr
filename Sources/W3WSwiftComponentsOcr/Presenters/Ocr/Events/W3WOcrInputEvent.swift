//
//  W3WOcrInputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import W3WSwiftAppEvents


/// input events for ocr
public enum W3WOcrInputEvent: String, W3WAppEventConvertable {
  
  case trackCameraMode
  case resetScanResult
  case startScanning
  /// stops the camera and ocr engine without emitting a `dismiss` output,
  /// for hosts that take over navigation themselves (e.g. QR hand-off)
  case stopScanning
  case capturePhoto
  case importPhoto
  case dismiss
  
  public func asAppEvent() -> W3WAppEvent {
    return W3WAppEvent(name: W3WAppEventName(value: "ocr." + self.rawValue))
  }
  
}
