//
//  W3WSelectableSuggestion.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 11/05/2025.
//

import Foundation
import W3WSwiftCore


class W3WSelectableSuggestion: Identifiable, ObservableObject {
  var id: UUID
  let suggestion: W3WSuggestion
  var selected: W3WLive<Bool?>
  
  
  init(suggestion: W3WSuggestion, selected: Bool? = false) {
    self.id = UUID()
    self.suggestion = suggestion
    self.selected = W3WLive<Bool?>(selected)
  }
  
  
  init(suggestion: W3WSuggestion, selected: W3WLive<Bool?>) {
    self.id = UUID()
    self.suggestion = suggestion
    self.selected = selected
  }
}
