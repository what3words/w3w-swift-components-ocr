//
//  W3WOcrOutputEvent.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import CoreGraphics
import W3WSwiftCore
import W3WSwiftAppEvents


/// output events for ocr
public enum W3WOcrOutputEvent {
  
  /// error
  case error(W3WError)
  
  /// when a 3wa is detected (not selected)
  case detected(W3WSuggestion)
  
  /// when the user selects an address
  case selected(W3WSuggestion)
  
  /// the import image button has been tapped
  case importImage
  
  /// the capture image button was tapped
  case captureButton(CGImage?)
  
  /// the live capture switch was switched
  case liveCaptureSwitch(Bool)
  
  /// footer button save tapped
  case saveSuggestions(title: String, suggestions: [W3WSuggestion])
  
  /// footer button share tapped
  case shareSuggestion(title: String, suggestion: W3WSuggestion)
  
  /// footer button view tapped
  case viewSuggestions(title: String, suggestions: [W3WSuggestion])
  
  /// the close button was tapped
  case dismiss
  
  /// pass though any analytic events
  case analytic(W3WAppEvent)
}

extension W3WOcrOutputEvent: W3WAppEventConvertable {
  public func asAppEvent() -> W3WAppEvent {
    switch self {

    case .error(let error):
      return W3WAppEvent(name: "ocr.error", parameters: ["error": .error(error)])
      
    case .detected(let suggestion):
      return W3WAppEvent(name: "ocr.detected", parameters: ["suggestion": .suggestion(suggestion)])
      
    case .selected(let suggestion):
      return W3WAppEvent(name: "ocr.selected", parameters: ["suggestion": .suggestion(suggestion)])
      
    case .importImage:
      return W3WAppEvent(name: "ocr.importImage")
      
    case .captureButton:
      return W3WAppEvent(name: "ocr.captureButton")
      
    case .liveCaptureSwitch(let value):
      return W3WAppEvent(name: "ocr.liveCaptureSwitch", parameters: ["value": .boolean(value)])
      
    case .saveSuggestions(let title, _):
      return W3WAppEvent(name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .shareSuggestion(let title, _):
      return W3WAppEvent(name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .viewSuggestions(let title, _):
      return W3WAppEvent(name: "ocr.footerButton", parameters: ["action": .text(title)])
      
    case .dismiss:
      return W3WAppEvent(name: "ocr.dismiss")
      
    case .analytic(let event):
      return event
    }
  }
}
