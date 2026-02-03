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
  
  /// indicates that if the ocr did collects any suggestions
  @Published public var hasSuggestions: Bool = false
  
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
  
  /// a view mdoel for still image ocr
  public init(ocr: W3WOcrProtocol,
              isProUser: W3WLive<Bool> = W3WLive<Bool>(true),
              translations: W3WTranslationsProtocol,
              theme: W3WLive<W3WTheme?>,
              language: W3WLive<W3WLanguage?>? = nil) {
    self.ocr = ocr
    self.translations = translations
    self.panelViewModel = W3WPanelViewModel(
      mode: .singleShot,
      isProUser: isProUser,
      theme: theme,
      language: language,
      translations: translations
    )
    
    // connect events to functions
    bind(theme: theme)
    
    // bind panelViewModel's output
    subscribe(to: panelViewModel.output) { [weak self] event in
      self?.handle(event: event)
    }
    
    panelViewModel.hasSuggestions
      .sink(receiveValue: { [weak self] hasSuggestions in
        self?.hasSuggestions = hasSuggestions
      })
      .store(in: &subscriptions)
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
  }
  
  
  /// handle inout events
  func handle(input: W3WOcrStillInputEvent) {
    switch input {
      
      // when an image comes in, scan it
      case .image(let i, let source):
        showImage(image: i)
        scanImage(image: i, source: source)
        
      case .isLoading:
        isLoading = true
        
      case .notLoading:
        isLoading = false
    }
  }
  
  private func handle(event: W3WPanelOutputEvent) {
    switch event {
    case .retry:
      output.send(.tryAgain)
      output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrTryAgain)))
      
    case .setSelectionMode(let flag):
      let event: W3WAppEventName = flag ? .ocrResultSelect : .ocrResultDeselect
      output.send(.analytic(W3WAppEvent(level: .analytic, name: event)))
      
    case .selectAllItems(let flag):
      let event: W3WAppEventName = flag ? .ocrResultSelectAll : .ocrResultDeselectAll
      output.send(.analytic(W3WAppEvent(level: .analytic, name: event)))
      
    case .viewSuggestion(let suggestion):
      output.send(.selected(suggestion))
      
    case let .saveSuggestions(title, suggestions):
      output.send(.saveSuggestions(title: title, suggestions: suggestions))
      output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrFooterButton, parameters: ["button": .text(title), "words": .text(makeWordsString(suggestions: suggestions))])))
      
    case let .shareSuggestion(title, suggestion):
      output.send(.shareSuggestion(title: title, suggestion: suggestion))
      output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrFooterButton, parameters: ["button": .text(title), "words": .text(makeWordsString(suggestions: [suggestion]))])))
      
    case let .viewSuggestions(title, suggestions):
      output.send(.viewSuggestions(title: title, suggestions: suggestions))
      output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrFooterButton, parameters: ["button": .text(title), "words": .text(makeWordsString(suggestions: suggestions))])))
    }
  }
  
  /// put an image up on the screen
  func showImage(image: CGImage?) {
    self.image = image
  }

  
  /// scan an image for three word addresses
  func scanImage(image: CGImage?, source: W3WOcrImageSource = .unknown) {
    guard let image else { return }
    isLoading = true
    
    W3WThread.runInBackground { [weak self, source] in
      self?.ocr.autosuggest(image: image, info: { _ in }) { [weak self] suggestions, error in
        W3WThread.runOnMain { [weak self] in
          guard let self else { return }
          isLoading = false
          if let error {
            output.send(.error(.other(error)))
          }
          
          if suggestions.isEmpty {
            output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrNoResultFound)))
          } else {
            if case .camera = source {
              output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrResultPhotoCapture)))
            }
            if case .photoLibrary = source {
              output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrResultPhotoImport)))
            }
          }
          
          panelViewModel.add(suggestions: suggestions)
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
    return "[\"" + retval.joined(separator: "\"],[\"") + "\"]"
  }

}
