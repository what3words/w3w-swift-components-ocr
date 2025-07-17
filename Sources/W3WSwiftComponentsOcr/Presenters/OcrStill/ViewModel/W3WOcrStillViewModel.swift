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
import W3WSwiftAppEvents


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
  
  /// the image to scan
  @Published public var isLoading: Bool = false
  
  /// the view model for the bottom sheet panel
  public var panelViewModel: W3WPanelViewModel
  
  /// the bottom sheet logic
  var bottomSheetLogic: W3WBottomSheetLogicProtocol

  /// allows the suggestions to be selected into a list
  var selectableSuggestionList = W3WLive<Bool>(true)

  
  /// a view mdoel for still image ocr
  public init(ocr: W3WOcrProtocol,
              footerButtons: [W3WSuggestionsViewAction],
              selectableSuggestionList: W3WLive<Bool> = W3WLive<Bool>(true),
              translations: W3WTranslationsProtocol,
              theme: W3WLive<W3WTheme?>) {
    self.ocr = ocr
    self.translations = translations
    self.selectableSuggestionList = selectableSuggestionList
    self.panelViewModel = W3WPanelViewModel(translations: translations)
    self.bottomSheetLogic = W3WBottomSheetLogicInsanity(suggestions: suggestions, panelViewModel: panelViewModel, footerButtons: footerButtons, translations: translations, viewType: .still, selectableSuggestionList: selectableSuggestionList)
    
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
      self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrFooterButton, parameters: ["button": .text(button.title), "words": .text(self?.makeWordsString(suggestions: suggestions))])))
    }
    
    // called when the try again button is pressed
    bottomSheetLogic.onTryAgain = { [weak self] in
      self?.output.send(.tryAgain)
      self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrTryAgain)))
    }

    // list for changes to the suggesitons list
    subscribe(to: suggestions.update) { [weak self] event in
      self?.panelViewModel.objectWillChange.send()
    }
    
    // when the user selects a single address
    suggestions.singleSelection = { [weak self] selection in
      self?.output.send(.selected(selection))
    }
    
    bottomSheetLogic.onSelectButton = { [weak self] in
      if (self?.bottomSheetLogic.selectMode ?? false) {
        self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultSelect)))
      } else {
        self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultDeselect)))
      }
    }
    
    bottomSheetLogic.onSelectAllButton = { [weak self] in
      if (self?.bottomSheetLogic.selectMode ?? false) {
        self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultSelectAll)))
      } else {
        self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultDeselectAll)))
      }
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
        
      case .isLoading:
        isLoading = true
        
      case .notLoading:
        isLoading = false
    }
  }
  
  
  /// put an image up on the screen
  func showImage(image: CGImage?) {
    self.image = image
  }

  
  /// scan an image for three word addresses
  func scanImage(image: CGImage?) {
    output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultPhotoImport, parameters: ["width": .number(image == nil ? nil : Float(image!.width)), "height": .number(image == nil ? nil : Float(image!.height))])))
    bottomSheetLogic.results(found: false)

    guard let image else { return }
    isLoading = true
    
    W3WThread.runInBackground { [weak self] in
      self?.ocr.autosuggest(image: image, info: { _ in }) { [weak self] suggestions, error in
        W3WThread.runOnMain { [weak self] in
          guard let self else { return }
          isLoading = false
          if let e = error {
            output.send(.error(.other(e)))
          }
          
          if suggestions.count == 0 {
            bottomSheetLogic.results(found: false)
            output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrNoResultFound)))
          } else {
            bottomSheetLogic.results(found: true)
            output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultPhotoCapture)))
          }
          
          // send suggestions to view
          bottomSheetLogic.add(suggestions: suggestions)
        }
      }
    }
  }
  
  public func dismissButtonPressed() {
    output.send(.dismiss)
  }
  
  
  // MARK: Utility


  func makeWordsString(suggestions: [W3WSuggestion]) -> String {
    let retval = suggestions.compactMap { $0.words }
    return retval.joined(separator: ",")
  }

}
