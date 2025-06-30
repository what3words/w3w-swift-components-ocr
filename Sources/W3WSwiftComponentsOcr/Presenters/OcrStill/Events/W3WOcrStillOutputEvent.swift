//
//  W3WOcrStillOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//


import CoreGraphics
import W3WSwiftCore
import W3WSwiftAppEvents


public enum W3WOcrStillOutputEvent: W3WAppEventConvertable {
  
  case error(W3WError)
  case footerButton(W3WSuggestionsViewAction, suggestions: [W3WSuggestion])
  case dismiss
  
  
  public func asAppEvent() -> W3WAppEvent {
    switch self {

      case .error(let error):
        return W3WAppEvent(type: Self.self, name: "ocr.error", parameters: ["error": .error(error)])

      case .footerButton(let action, suggestions: let suggestions):
        return W3WAppEvent(type: Self.self, name: "ocr.footerButton", parameters: ["action": .text(action.title)])

      case .dismiss:
        return W3WAppEvent(type: Self.self, name: "ocr.dismiss")
    }
  }

}
