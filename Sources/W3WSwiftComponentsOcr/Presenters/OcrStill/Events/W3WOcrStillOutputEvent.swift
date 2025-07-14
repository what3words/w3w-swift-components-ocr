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
  
  /// an error happened
  case error(W3WError)
  
  /// footer button tapped
  case footerButton(W3WSuggestionsViewAction, suggestions: [W3WSuggestion])
  
  /// when the user selects an address
  case selected(W3WSuggestion)
  
  /// try again button tapped
  case tryAgain
  
  /// dismiss teh view
  case dismiss
  
  /// pass though any analytic events
  case analytic(W3WAppEvent)
  
  
  public func asAppEvent() -> W3WAppEvent {
    switch self {
      
    case .error(let error):
      return W3WAppEvent(type: Self.self, name: "ocr.error", parameters: ["error": .error(error)])
      
    case .footerButton(let action, suggestions: let suggestions):
      return W3WAppEvent(type: Self.self, name: "ocr.footerButton", parameters: ["action": .text(action.title)])
      
    case .selected(let suggestion):
      return W3WAppEvent(type: Self.self, name: "ocr.selected", parameters: ["suggestion": .suggestion(suggestion)])
      
    case .tryAgain:
      return W3WAppEvent(type: Self.self, name: "ocr.tryAgain")
      
    case .dismiss:
      return W3WAppEvent(type: Self.self, name: "ocr.dismiss")
      
    case .analytic(let event):
      return event
    }
  }
  
}
