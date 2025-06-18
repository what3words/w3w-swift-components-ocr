//
//  W3WOcrOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import CoreGraphics
import W3WSwiftCore
import W3WSwiftAppEvents


public enum W3WOcrOutputEvent: W3WAppEventConvertable {
  
  case error(W3WError)
  case importImage
  case image(CGImage)
  case captureButton
  case liveCaptureSwitch(Bool)
  case footerButton(W3WSuggestionsViewAction, suggestions: [W3WSuggestion])
  case dismiss

  
  public func asAppEvent() -> W3WAppEvent {
    switch self {
      case .error(let error):
        return W3WAppEvent(type: Self.self, level: .error, name: .error, parameters: ["error" : .error(error)])

      case .importImage:
        return W3WAppEvent(type: Self.self, level: .log, name: .ocrPhotoImport)

      case .image(_):
        return W3WAppEvent(type: Self.self, level: .log, name: "ocr.scan.image.chosen")

      case .captureButton:
        return W3WAppEvent(type: Self.self, level: .log, name: .ocrPhotoCapture)

      case .liveCaptureSwitch(let on):
        return W3WAppEvent(type: Self.self, level: .log, name: on ? .ocrLiveScanOn : .ocrLiveScanOff)

      case .footerButton(let action, suggestions: let suggestions):
        return W3WAppEvent(type: Self.self, level: .log, name: "ocr.footer.button", parameters: ["action": .text(action.title)])

      case .dismiss:
        return W3WAppEvent(type: Self.self, level: .log, name: "ocr.dismiss")
    }
  }
  
}
 
