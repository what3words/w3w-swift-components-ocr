//
//  W3WBottomSheetManager.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 29/06/2025.
//

import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters


/// manages a bottom sheet on an ocr screen
class W3WBottomSheetLogic: W3WEventSubscriberProtocol {
  var subscriptions = W3WEventsSubscriptions()

  /// the model for the panel in the bottom sheet
  var panelViewModel: W3WPanelViewModel
  
  /// the sugggestions being displayed
  var suggestions: W3WSelectableSuggestions
  
  /// the not found message
  lazy var notFound =  W3WPanelItem.heading(W3WLive<W3WString>(translations.get(id: "ocr_import_photo_errorMessage").w3w))

  /// the invitation to scan message
  lazy var scanMessage =  W3WPanelItem.heading(W3WLive<W3WString>(translations.get(id: "ocr_scan_3wa").w3w))

  /// the invitation to scan message
  lazy var blankMessage =  W3WPanelItem.heading(W3WLive<W3WString>("".w3w))

  /// the try again button
  var tryAgainItem: W3WPanelItem = .button(.init(onTap: {}))

  /// the buttons at the bottom that show conditionally
  var footerButtons: [W3WSuggestionsViewAction]

  /// the text shown next to the footer buttons
  var footerText = W3WLive<W3WString>("")
  
  /// the translations
  var translations: W3WTranslationsProtocol
  
  /// indicates if we are in selection mode or in regular mode
  var selectMode = false

  /// keeps track of if the selection button is showing - maybe this could be a computed value?
  var selectionButtonsShowing = false
  
  /// callback for when a button is tapped containing the button tpped and the currently selected suggestions
  var onButton: (W3WSuggestionsViewAction, [W3WSuggestion]) -> () = { _,_ in }
  
  /// when the try again button is tapped
  var onTryAgain: () -> () = { }
  
  /// when the select button is tapped
  var onSelectButton: () -> () = { }
  
  /// when the select all button is tapped
  var onSelectAllButton: () -> () = { }

  /// indicates the contect of the bottom sheet - video or still image
  var viewType: W3WOcrViewType
  
  /// allows the suggestions to be selected into a list
  var selectableSuggestionList = W3WLive<Bool>(true)

  /// indicates that nothing was found in a still image
  var resultsFound: Bool? = nil
  
  
  // MARK: Computed Vars

  
  var isAllSelected: Bool {
    return suggestions.selectedCount() == suggestions.count()
  }
  
  
  // MARK: Buttons
  

  /// the select button representation
  lazy var selectButton = W3WButtonData(title: translations.get(id: "ocr_selectButton"), highlight: .secondary) { [weak self] in
    self?.selectMode.toggle()
    self?.suggestions.make(selectable: self?.selectMode ?? false)
    self?.onSelectButton()
  }
  
  /// the select all button representation
  lazy var selectAllButton = W3WButtonData(title: translations.get(id: "ocr_select_allButton"), highlight: .secondary) { [weak self] in
    self?.selectMode = true
    if self?.isAllSelected ?? false {
      self?.suggestions.setAll(selected: false)
    } else {
      self?.suggestions.setAll(selected: true)
    }
    self?.onSelectAllButton()
  }

  
  // MARK: Innit
  
  
  /// manages a bottom sheet on an ocr screen
  init(suggestions: W3WSelectableSuggestions, panelViewModel: W3WPanelViewModel, footerButtons: [W3WSuggestionsViewAction], translations: W3WTranslationsProtocol, viewType: W3WOcrViewType, selectableSuggestionList: W3WLive<Bool>) {
    self.suggestions    = suggestions
    self.panelViewModel = panelViewModel
    self.footerButtons  = footerButtons
    self.translations    = translations
    self.viewType          = viewType
    self.selectableSuggestionList = selectableSuggestionList

    // create the try again button
    let tryAgainButton = W3WButtonData(
      icon: nil,
      title: translations.get(id: "ocr_import_photo_tryAgainButton")
    ) { [weak self] in
      self?.onTryAgain()
    }
    tryAgainItem = W3WPanelItem.button(tryAgainButton)
    
    // initial set up of the panel
    panelViewModel.input.send(.add(item: .suggestions(suggestions)))

    // set up the footer
    updateFooterStatus()

    // connect the events pipelines
    bind()
  }
  
  
  // MARK: Events
  
  
  /// connect events to functions
  func bind() {
    subscribe(to: suggestions.update) { [weak self] event in
      self?.updateFooterStatus()
    }
  }
  
  
  // MARK: Commands
  
  
  /// tells the view that OCR did it's work on a still image and it found nothing
  func results(found: Bool) {
    resultsFound = found
    updateFooterStatus()
  }
  
  
  /// logic to update the footer text and buttons
  func add(suggestions theSuggestions: [W3WSuggestion]?) {
    if let s = theSuggestions {
      if !does(list: suggestions.allSuggestions, alreadyContain: s) {
        suggestions.add(suggestions: s, selected: selectMode ? false : nil)
        updateFooterStatus()
      }
    }
  }
  
  
  /// checks to see if any suggestion in `alreadyContains` is in the `list`
  func does(list: [W3WSuggestion], alreadyContain: [W3WSuggestion]) -> Bool {
    var retval = false
    
    for suggestion in alreadyContain {
      retval = retval || list.contains(where: { s in s.words == suggestion.words })
    }
    
    return retval
  }
  
  /// logic to update the footer text and buttons
  func updateFooterStatus() {
    let footer: W3WPanelItem = .buttons(convert(footerButtons: footerButtons), text: footerText)
    
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
      
    if suggestions.count() > 0 && !selectionButtonsShowing && selectableSuggestionList.value {
      panelViewModel.input.send(.remove(item: notFound))
      selectionButtonsShowing = true
      showSelectionButtons()
    }
    
    if suggestions.count() == 0 && selectionButtonsShowing || !selectableSuggestionList.value {
      panelViewModel.input.send(.remove(item: notFound))
      panelViewModel.input.send(.footer(item: nil))
      hideSelectionButtons()
      selectionButtonsShowing = false
    }
    
    updateFooterText()
    updateSelectButtons()
  }

  
  /// update the text in the footer
  func updateFooterText() {
    footerText.send("\(suggestions.selectedCount()) \(translations.get(id: "ocr_w3wa_selected_number"))".w3w)
  }
 
  
  /// show the buttons at the top [select] and [select all]
  func showSelectionButtons() {
    panelViewModel.input.send(.header(item: .buttons([selectButton, selectAllButton])))
  }
  
  
  /// hide the buttons at the top [select] and [select all]
  func hideSelectionButtons() {
    W3WThread.runIn(duration: .seconds(5.0)) { [weak self] in
      if let self {
        self.panelViewModel.input.send(.header(item: nil))
      }
    }
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
  
  
  // MARK: Utility
  
  
  /// make button data out of an array of suggestions actions
  func convert(footerButtons: [W3WSuggestionsViewAction]) -> [W3WButtonData] {
    var buttons = [W3WButtonData]()

    for footerButton in footerButtons {
      if !footerButton.onlyForSingleSuggestion || (footerButton.onlyForSingleSuggestion && suggestions.selectedCount() == 1) {
        buttons.append(W3WButtonData(icon: footerButton.icon, title: footerButton.title, onTap: { [weak self] in
          if let s = self {
            self?.onButton(footerButton, s.suggestions.selectedSuggestions)
          }
        }))
      }
    }
    
    return buttons
  }

  
}
