//
//  W3WBottomSheetLogicInsanity.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 29/06/2025.
//

import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters


/// manages a bottom sheet on an ocr screen in a way that
/// kind of doesn't make sense? Select button makes all items
/// selectable but stays highlighted even if they are not
/// selectable anymore. Select All selects all, and stays
/// highlighted even if no items are selected anymore
class W3WBottomSheetLogicInsanity: W3WBottomSheetLogicBase {
  // MARK: Innit
  
  
  /// manages a bottom sheet on an ocr screen
  override init(suggestions: W3WSelectableSuggestions, panelViewModel: W3WPanelViewModel, footerButtons: [W3WSuggestionsViewAction], translations: W3WTranslationsProtocol, viewType: W3WOcrViewType, selectableSuggestionList: W3WLive<Bool>) {
    super.init(suggestions: suggestions, panelViewModel: panelViewModel, footerButtons: footerButtons, translations: translations, viewType: viewType, selectableSuggestionList: selectableSuggestionList)
    
    // default to non-slectable items
    suggestions.make(selectable: false)
    hideSelectionButtons()
  }
  
  
  // MARK: Events

  
  override func selectButtonTapped() {
    selectMode.toggle()
    suggestions.make(selectable: selectMode)
    selectButton.highlight = selectMode ? .primary : .secondary
    onSelectButton()
    
    if selectAllButton.highlight == .primary {
      suggestions.setAll(selected: false)
      selectButton.highlight = .primary
      selectAllButton.highlight = .secondary
    }
  }
  
  
  override func selectAllButtonTapped() {
    selectMode = true

    if isAllSelected {
      suggestions.setAll(selected: false)
      selectAllButton.highlight = .secondary
      
    } else {
      suggestions.setAll(selected: true)
      selectAllButton.highlight = .primary
      selectButton.highlight = .secondary
    }
    
    onSelectAllButton()
  }

 
  // Logic
  
  
  /// logic to update the footer text and buttons
  override func updateFooterStatus() {
    let footer: W3WPanelItem = .buttonsAndTitle(convert(footerButtons: footerButtons), text: footerText)
    
    // if there are selected suggestions then show the footer
    if suggestions.selectedCount() > 0 {
      panelViewModel.input.send(.footer(item: footer))
    } else {
      panelViewModel.input.send(.footer(item: nil))
      panelViewModel.input.send(.remove(item: tryAgainItem))
      panelViewModel.input.send(.remove(item: notFound))
      if let resultsFound, !resultsFound {
        panelViewModel.input.send(.add(item: tryAgainItem))
        panelViewModel.input.send(.add(item: notFound))
      }
    }
    
    // if there any suggestions & those are selectable, i.e pro mode, then show selection buttons
    if suggestions.count() > 0 && selectableSuggestionList.value {
      showSelectionButtons()
    } else {
      hideSelectionButtons()
    }
    
    updateFooterText()
  }

}
