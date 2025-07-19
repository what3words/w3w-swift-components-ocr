//
//  W3WBottomSheetManager.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 29/06/2025.
//

import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters


/// manages a bottom sheet on an ocr screen in a way that
/// makes sense. Select button makes all items selectable
/// and Select All selects all, and is only highlighted
/// when all items are selected
class W3WBottomSheetLogicSensible: W3WBottomSheetLogicBase {

  // MARK: Innit
  
  
  /// manages a bottom sheet on an ocr screen
  override init(suggestions: W3WSelectableSuggestions, panelViewModel: W3WPanelViewModel, footerButtons: [W3WSuggestionsViewAction], translations: W3WTranslationsProtocol, viewType: W3WOcrViewType, selectableSuggestionList: W3WLive<Bool>) {
    super.init(suggestions: suggestions, panelViewModel: panelViewModel, footerButtons: footerButtons, translations: translations, viewType: viewType, selectableSuggestionList: selectableSuggestionList)
  }
  
  
  // MARK: Events

  
  override func selectButtonTapped() {
    selectMode.toggle()
    suggestions.make(selectable: selectMode)
    onSelectButton()
  }
  
  
  override func selectAllButtonTapped() {
    selectMode = true
    if isAllSelected {
      suggestions.setAll(selected: false)
    } else {
      suggestions.setAll(selected: true)
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
    }

    // if this is for a still image, then there are three possible states
    if viewType == .still {
      if let found = resultsFound {
        
        // clear previous items
        panelViewModel.input.send(.remove(item: blankMessage))
        panelViewModel.input.send(.remove(item: tryAgainItem))
        panelViewModel.input.send(.remove(item: notFound))

        // results were found
        if found {

        // results were not found
        } else {
          panelViewModel.input.send(.add(item: tryAgainItem))
          panelViewModel.input.send(.add(item: notFound))
        }
        
      // view just started up, results are niether found or unfound
      } else {
        panelViewModel.input.send(.add(item: blankMessage))
      }
    }
    
//    if viewType == .still && resultsFound == false {
//      panelViewModel.input.send(.remove(item: blankMessage))
//      panelViewModel.input.send(.remove(item: scanMessage))
//      panelViewModel.input.send(.remove(item: tryAgainItem))
//      panelViewModel.input.send(.remove(item: notFound))
//      if suggestions.count() == 0 {
//        panelViewModel.input.send(.add(item: tryAgainItem))
//        panelViewModel.input.send(.add(item: notFound))
//      }
//    }
//
//    if viewType == .still && (resultsFound == nil) {
//      panelViewModel.input.send(.add(item: blankMessage))
//    }
      
    if suggestions.count() > 0 && !areSelectionButtonsVisible && selectableSuggestionList.value {
      panelViewModel.input.send(.remove(item: notFound))
      areSelectionButtonsVisible = true
      showSelectionButtons()
    }
    
    if suggestions.count() == 0 && areSelectionButtonsVisible || !selectableSuggestionList.value {
      panelViewModel.input.send(.remove(item: notFound))
      panelViewModel.input.send(.footer(item: nil))
      hideSelectionButtons()
      areSelectionButtonsVisible = false
    }
    
    updateFooterText()
    updateSelectButtons()
  }

  
  func updateSelectButtons() {
    if isAllSelected {
      selectAllButton.highlight = .primary
    } else {
      selectAllButton.highlight = .secondary
    }
    
    if selectMode {
      selectButton.highlight = .primary
    } else {
      selectButton.highlight = .secondary
    }
  }

 
  
}
