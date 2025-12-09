//
//  W3WOcrStillOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//


import CoreGraphics
import W3WSwiftCore
import W3WSwiftAppEvents


public enum W3WOcrStillOutputEvent {
  
  /// an error happened
  case error(W3WError)
  
  /// when the user selects an address
  case selected(W3WSuggestion)
  
  /// try again button tapped
  case tryAgain
  
  /// footer button save tapped
  case saveSuggestions(title: String, suggestions: [W3WSuggestion])
  
  /// footer button share tapped
  case shareSuggestion(title: String, suggestion: W3WSuggestion)
  
  /// footer button view tapped
  case viewSuggestions(title: String, suggestions: [W3WSuggestion])
  
  /// dismiss teh view
  case dismiss
  
  /// pass though any analytic events
  case analytic(W3WAppEvent)
}

extension W3WOcrStillOutputEvent: W3WAppEventConvertable {
  public func asAppEvent() -> W3WAppEvent {
    switch self {
      
    case .error(let error):
      return W3WAppEvent(type: Self.self, name: "ocr.error", parameters: ["error": .error(error)])
      
    case .selected(let suggestion):
      return W3WAppEvent(type: Self.self, name: "ocr.selected", parameters: ["suggestion": .suggestion(suggestion)])
      
    case .tryAgain:
      return W3WAppEvent(type: Self.self, name: "ocr.tryAgain")
      
    case .saveSuggestions(let title, _):
      return W3WAppEvent(type: Self.self, name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .shareSuggestion(let title, _):
      return W3WAppEvent(type: Self.self, name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .viewSuggestions(let title, _):
      return W3WAppEvent(type: Self.self, name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .dismiss:
      return W3WAppEvent(type: Self.self, name: "ocr.dismiss")
      
    case .analytic(let event):
      return event
    }
  }
}
