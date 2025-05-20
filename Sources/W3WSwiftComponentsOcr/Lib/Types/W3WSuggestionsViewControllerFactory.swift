//
//  W3WSuggestionHandlerViewFactory.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 19/05/2025.
//

import UIKit
import W3WSwiftCore
import W3WSwiftThemes


public class W3WSuggestionsViewControllerFactory {
  
  //func make(suggestions: [W3WSuggestion]) -> UIViewController
  
  var icon: W3WImage?
  
  var title: String?
  
  var make: ([W3WSuggestion]) -> (UIViewController)
  

  public init(icon: W3WImage? = nil, title: String? = nil, make: @escaping ([W3WSuggestion]) -> UIViewController) {
    self.icon = icon
    self.title = title
    self.make = make
  }
  
}
