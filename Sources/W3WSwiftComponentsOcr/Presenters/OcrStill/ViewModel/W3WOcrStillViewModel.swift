//
//  W3WOcrStillViewModel.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 28/06/2025.
//

import Combine
import CoreGraphics
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters


/// a view model for still image ocr
public class W3WOcrStillViewModel: W3WOcrStillViewModelProtocol, W3WEventSubscriberProtocol {
  
  public var subscriptions = W3WEventsSubscriptions()
  
  /// input events for still imagfe ocr
  public var input = W3WEvent<W3WOcrStillInputEvent>()
  
  /// output events for still imagfe ocr
  public var output = W3WEvent<W3WOcrStillOutputEvent>()
  
  /// the suggestoins found in the image
  var suggestions = W3WSelectableSuggestions()
  
  /// the translations
  public var translations: W3WTranslationsProtocol
  
  /// the ocr service to do the scanning
  public var ocr: W3WOcrProtocol

  /// the scheme to use
  @Published public var scheme: W3WScheme?
  
  /// the image to scan
  @Published public var image: CGImage?
  
  /// the view model for the bottom sheet panel
  public var panelViewModel = W3WPanelViewModel()
  
  /// the bottom sheet logic
  let bottomSheetLogic: W3WBottomSheetLogic

  
  /// a view mdoel for still image ocr
  public init(ocr: W3WOcrProtocol, footerButtons: [W3WSuggestionsViewAction], translations: W3WTranslationsProtocol, theme: W3WLive<W3WTheme?>) {
    self.ocr = ocr
    self.translations = translations
    self.bottomSheetLogic = W3WBottomSheetLogic(suggestions: suggestions, panelViewModel: panelViewModel, footerButtons: footerButtons, translations: translations)
    
    // connect events to functions
    bind(theme: theme)
  }
  
  
  /// connect events to functions
  func bind(theme: W3WLive<W3WTheme?>) {
    // follow the theme changes
    subscribe(to: theme) { [weak self] theme in
      self?.scheme = theme?.ocrBottomSheetScheme()
    }
    
    // listen to input events
    subscribe(to: input) { [weak self] event in
      self?.handle(input: event)
    }
    
    // listen for bottom sheet button presses
    bottomSheetLogic.onButton = { [weak self] button, suggestions in
      self?.output.send(.footerButton(button, suggestions: suggestions))
    }

    // list for changes to the suggesitons list
    subscribe(to: suggestions.update) { [weak self] event in
      self?.panelViewModel.objectWillChange.send()
    }
  }
  
  
  /// handle inout events
  func handle(input: W3WOcrStillInputEvent) {
    switch input {
      
      // when an image comes in, scan it
      case .image(let i):
        showImage(image: i)
        scanImage(image: i)
        bottomSheetLogic.updateFooterStatus()
    }
  }
  
  
  /// put an image up on the screen
  func showImage(image: CGImage?) {
    self.image = image
  }

  
  /// scan an image for three word addresses
  func scanImage(image: CGImage?) {
    if let i = image {
      ocr.autosuggest(image: i, info: { _ in }) { [weak self] suggestions, error in
        if let e = error {
          self?.output.send(.error(.other(e)))
        }
        
        // send suggestions to view
        self?.bottomSheetLogic.add(suggestions: suggestions)
      }
    }
  }
  
  public func dismissButtonPressed() {
    output.send(.dismiss)
  }
}
