//
//  W3WMutliPurposeItem.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import Foundation
import W3WSwiftCore
import W3WSwiftThemes
//import W3WSwiftAppTypes

@available(*, deprecated, message: "W3WNotificaiton should be moved to W3WSwiftDesign if it's to work here")
public struct W3WNotification { }

public enum W3WPanelItem: Equatable, CustomStringConvertible {
  
  case buttons([W3WButtonData], text: W3WLive<W3WString>? = nil)
  case tappableRow(icon: W3WImage, text: W3WLive<W3WString>)
  case address(address: String, [W3WButtonData])
  case message(W3WLive<W3WString>)
  case suggestion(W3WSuggestion, selected: W3WLive<Bool>? = nil)
  case suggestions(W3WSelectableSuggestions)
  //case selectableSuggestion(W3WSuggestion, W3WLive<Bool>)
  case segmentedControl([W3WButtonData])
  case route(time: W3WLive<W3WDuration>, distance: W3WLive<W3WDistance>, eta: W3WLive<Date>, [W3WButtonData])
  case routeFinished(W3WSuggestion)
  case title(W3WLive<W3WString>)
  case heading(W3WLive<W3WString>)
  case notification(W3WNotification)
  case actionItem(icon: W3WImage, text: W3WLive<W3WString>, W3WButtonData)

  
  public static func == (lhs: W3WPanelItem, rhs: W3WPanelItem) -> Bool {
    switch (lhs, rhs) {
      case (.message(let lhsString), .message(let rhsString)):
        return lhsString.value.asString() == rhsString.value.asString()
        
      default:
        return false
    }
  }
  
  
  public var description: String {
    get {
      switch self {
          
        case .buttons(let buttons, text: let text):
          return "\(buttons.count) buttons"
        case .tappableRow(icon: let icon, text: let text):
          return "row: " + text.value.asString()
          
        case .address(address: let address, _):
          return "address: " + address.description

        case .message(let message):
          return message.value.description
          
        case .suggestion(let suggestion, _):
          return suggestion.description
          
        case .suggestions(let suggestions):
          return suggestions.suggestions.description
          
        //case .selectableSuggestion(let suggestion, let on):
        //  return suggestion.description + " \(on.value ? "on" : "off")"
          
        case .segmentedControl(let control):
          return "Control with \(control.count) values"

        case .route(time: let time, distance: let distance, eta: let eta, _):
          return "route: \(time.value.seconds) seconds, \(distance.value.description)"
          
        case .routeFinished(_):
          return "route finished"
          
        case .title(let text):
          return text.value.asString()
          
        case .heading(let text):
          return text.value.asString()

        case .notification(let notification):
          return "notification"
          
        case .actionItem(icon: let icon, text: let text, _):
          return "action:" + text.value.asString()
      }
    }
  }


}
