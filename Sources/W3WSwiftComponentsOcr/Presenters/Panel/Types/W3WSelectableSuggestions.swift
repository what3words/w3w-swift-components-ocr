//
//  W3WSelectableSuggestions.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 11/05/2025.
//

import Combine
import W3WSwiftCore


public class W3WSelectableSuggestions {
  
  var suggestions = [W3WSelectableSuggestion]()

  var update: () -> () = { }
  
  public func add(suggestion: W3WSuggestion?, selected: Bool? = nil) {
    if let s = suggestion {
      if let words = s.words {
        if !suggestions.contains(where: { s in s.suggestion.words == words }) {
          suggestions.insert(W3WSelectableSuggestion(suggestion: s, selected: selected), at: 0)
        }
      }
    }
    update()
  }

  
  public func add(suggestions: [W3WSuggestion], selected: Bool? = nil) {
    for suggestion in suggestions {
      add(suggestion: suggestion, selected: selected)
    }
    update()
  }
  
}
