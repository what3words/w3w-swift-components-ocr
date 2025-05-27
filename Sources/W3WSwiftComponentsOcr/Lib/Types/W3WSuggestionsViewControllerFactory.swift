//
//  W3WSuggestionHandlerViewFactory.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 19/05/2025.
//

import UIKit
import W3WSwiftCore
import W3WSwiftThemes


@available(*, deprecated, renamed: "W3WSuggestionsViewAction")
public typealias W3WSuggestionsViewControllerFactory = W3WSuggestionsViewAction


//public enum W3WViewAction {
//  case viewControllerFactory(forSuggestions: ([W3WSuggestion]) -> (UIViewController))
//  case execute(forSuggestions: ([W3WSuggestion]) -> ())
//}

public typealias W3WViewAction = ([W3WSuggestion], UIViewController?) -> ()


public class W3WSuggestionsViewAction {
  
  var icon: W3WImage?
  
  var title: String?
  
  var action: W3WViewAction
  
  var onlyForSingleSuggestion: Bool
  

  public init(icon: W3WImage? = nil, title: String? = nil, onlyForSingleSuggestion: Bool = false, action: @escaping W3WViewAction) {
    self.icon = icon
    self.title = title
    self.onlyForSingleSuggestion = onlyForSingleSuggestion
    self.action = action
  }
  
}
