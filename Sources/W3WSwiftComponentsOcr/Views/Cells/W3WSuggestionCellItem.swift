//
//  W3WSuggestionCellItem.swift
//  
//
//  Created by Thy Nguyen on 20/12/2023.
//

#if canImport(UIKit)
import UIKit
import W3WSwiftCore
import W3WSwiftDesign

public struct W3WSuggestionCellItem: Hashable {
  let identifier: String
  let suggestion: W3WSuggestion?
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  public static func == (lhs: W3WSuggestionCellItem, rhs: W3WSuggestionCellItem) -> Bool {
    lhs.identifier == rhs.identifier
  }
}

public extension W3WSuggestionCellItem {
  init(suggestion: W3WSuggestion) {
    identifier = suggestion.words ?? ""
    self.suggestion = suggestion
  }
}

public extension W3WSuggestionsTableViewCell {
  func configure(with item: W3WSuggestionCellItem?) {
    set(suggestion: item?.suggestion)
  }
}
#endif
