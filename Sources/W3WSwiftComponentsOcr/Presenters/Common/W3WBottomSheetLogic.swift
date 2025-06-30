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

  /// the try again button
  let tryAgainItem: W3WPanelItem

  /// the buttons at the bottom that show conditionally
  var footerButtons: [W3WSuggestionsViewAction]

  /// the footer that holds teh bottom buttons
  var footer: W3WPanelItem?

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

  
  // Buttons
  

  /// the select button representation
  lazy var selectButton = W3WButtonData(title: "select") { [weak self] in
    self?.selectMode.toggle()
    self?.suggestions.make(selectable: self?.selectMode ?? false)
  }
  
  /// the select all button representation
  lazy var selectAllButton = W3WButtonData(title: "select all") { [weak self] in
    self?.selectMode = true
    self?.suggestions.selectAll()
  }

  
  // MARK: Innit
  
  
  /// manages a bottom sheet on an ocr screen
  init(suggestions: W3WSelectableSuggestions, panelViewModel: W3WPanelViewModel, footerButtons: [W3WSuggestionsViewAction], translations: W3WTranslationsProtocol) {
    self.suggestions = suggestions
    self.panelViewModel = panelViewModel
    self.footerButtons = footerButtons
    self.translations = translations

    // create the try again button
    let tryAgainButton = W3WButtonData(icon: nil, title: translations.get(id: "ocr_import_photo_tryAgainButton")) {
      print("reload") // make htis work
    }
    tryAgainItem = W3WPanelItem.buttons([tryAgainButton], text: W3WLive<W3WString>("".w3w))
    
    // initial set up of the panel
    panelViewModel.input.send(.footer(item: footer))
    panelViewModel.input.send(.add(item: .suggestions(suggestions)))

    // set up the footer
    updateFooterStatus()

    // DEBUG
    suggestions.add(suggestion: W3WBaseSuggestion(words: "fancy.duck.cloud"))

    // connect the events pipelines
    bind()
  }
  
  
  /// connect events to functions
  func bind() {
    subscribe(to: suggestions.update) { [weak self] event in
      self?.updateFooterStatus()
    }
  }
  
  
  /// logic to update the footer text and buttons
  func updateFooterStatus() {
    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
    
    if suggestions.selectedCount() > 0 {
      panelViewModel.input.send(.footer(item: footer))
    } else {
      panelViewModel.input.send(.footer(item: nil))
    }

    panelViewModel.input.send(.remove(item: tryAgainItem))
    panelViewModel.input.send(.remove(item: notFound))
    if suggestions.count() == 0 {
      panelViewModel.input.send(.add(item: tryAgainItem))
      panelViewModel.input.send(.add(item: notFound))
    }
    
    if suggestions.count() > 0 && !selectionButtonsShowing {
      panelViewModel.input.send(.remove(item: notFound))
      selectionButtonsShowing = true
      showSelectionButtons()
    }
    
    if suggestions.count() == 0 && selectionButtonsShowing {
      panelViewModel.input.send(.remove(item: notFound))
      panelViewModel.input.send(.footer(item: nil))
      hideSelectionButtons()
      selectionButtonsShowing = false
    }
    
    updateFooterText()
  }

  
  /// update the text in the footer
  func updateFooterText() {
    footerText.send("\(suggestions.selectedCount()) \(translations.get(id: "ocr_w3wa_selected_number"))".w3w)
  }
 
  
  /// show the buttons at the top [select] and [select all]
  func showSelectionButtons() {
    panelViewModel.input.send(.add(item: .buttons([selectButton, selectAllButton])))
  }
  
  
  /// hide the buttons at the top [select] and [select all]
  func hideSelectionButtons() {
    W3WThread.runIn(duration: .seconds(5.0)) { [weak self] in
      if let s = self {
        s.panelViewModel.input.send(.remove(item: .buttons([s.selectButton, s.selectAllButton])))
      }
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
