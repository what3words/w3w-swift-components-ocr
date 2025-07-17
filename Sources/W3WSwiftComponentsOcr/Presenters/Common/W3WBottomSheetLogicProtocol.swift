//
//  W3WBottomSheetLogicProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/07/2025.
//

import W3WSwiftPresenters


protocol W3WBottomSheetLogicProtocol {
  
  /// the sugggestions being displayed
  var suggestions: W3WSelectableSuggestions { get set }

  /// indicates if we are in selection mode or in regular mode
  var selectMode: Bool { get set }

  /// callback for when a button is tapped containing the button tpped and the currently selected suggestions
  var onButton: (W3WSuggestionsViewAction, [W3WSuggestion]) -> () { get set }
  
  /// when the try again button is tapped
  var onTryAgain: () -> ()  { get set }
  
  /// when the select button is tapped
  var onSelectButton: () -> ()  { get set }
  
  /// when the select all button is tapped
  var onSelectAllButton: () -> ()  { get set }

  
  func add(suggestions theSuggestions: [W3WSuggestion]?)
  
  func updateFooterStatus()
  
  func updateFooterText()
  
  func results(found: Bool)
}
