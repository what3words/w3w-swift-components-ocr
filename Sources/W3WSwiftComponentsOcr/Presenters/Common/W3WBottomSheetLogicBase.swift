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
class W3WBottomSheetLogicBase: W3WBottomSheetLogicProtocol, W3WEventSubscriberProtocol {
  
  /// keeps track of if the selection button is showing - maybe this could be a computed value?
  var areSelectionButtonsVisible: Bool = false
  
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
  
  var selectedSuggestionsCount = W3WLive<W3WString>("")
  
  /// the translations
  var translations: W3WTranslationsProtocol
  
  /// indicates if we are in selection mode or in regular mode
  var selectMode = false
  
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
    self?.selectButtonTapped()
  }
  
  /// the select all button representation
  lazy var selectAllButton = W3WButtonData(title: translations.get(id: "ocr_select_allButton"), highlight: .secondary) { [weak self] in
    self?.selectAllButtonTapped()
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
  
  
  func reset() {
    selectMode = false
    areSelectionButtonsVisible = false
    suggestions.clear()
    updateFooterStatus()
    hideSelectionButtons()
  }
  
  
  func selectButtonTapped() {
  }
  
  
  func selectAllButtonTapped() {
  }

  
  // MARK: Commands
  
  
  /// tells the view that OCR did it's work on a still image and it found nothing
  func results(found: Bool) {
    resultsFound = found
    updateFooterStatus()
  }
  
  
  /// logic to update the footer text and buttons
  func add(suggestions theSuggestions: [W3WSuggestion]?) {
    guard let theSuggestions else { return }
    let filtered = theSuggestions.filter { suggestion in
      !suggestions.allSuggestions.contains(where: { $0.words == suggestion.words })
    }
    if !filtered.isEmpty {
      suggestions.add(suggestions: theSuggestions, selected: selectMode ? false : nil)
      updateFooterStatus()
    }
  }
  
  
  /// logic to update the footer text and buttons
  func updateFooterStatus() {
  }

  
  /// update the text in the footer
  func updateFooterText() {
    selectedSuggestionsCount.send("\(suggestions.selectedCount())".w3w)
    footerText.send("\(suggestions.selectedCount()) \(translations.get(id: "ocr_w3wa_selected_number"))".w3w)
  }
 
  
  /// show the buttons at the top [select] and [select all]
  func showSelectionButtons() {
    panelViewModel.input.send(.header(item: .buttons([selectButton, selectAllButton])))
  }
  
  
  /// hide the buttons at the top [select] and [select all]
  func hideSelectionButtons() {
    panelViewModel.input.send(.remove(item: .buttons([selectButton, selectAllButton])))
  }

  
  /// show the title `Scanned` at the top
  func showScannedTitle() {
    panelViewModel.input.send(.header(item: .title(translations.get(id: "scan_state_found"))))
  }
  
  
  /// hide the title `Scanned` at the top
  func hideScannedTitle() {
    panelViewModel.input.send(.remove(item: .title(translations.get(id: "scan_state_found"))))
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
