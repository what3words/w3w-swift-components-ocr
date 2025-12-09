//
//  W3WOcrViewModel.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import Combine
import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters
import W3WSwiftAppEvents


/// model for the ocr view
public class W3WOcrViewModel: W3WOcrViewModelProtocol, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  /// ocr inout events
  public var input = W3WEvent<W3WOcrInputEvent>()
  
  /// ocr output events
  public var output = W3WEvent<W3WOcrOutputEvent>()
  
  /// theme for the view
  public var theme: W3WLive<W3WTheme?>

  /// used to be just a scheme, upgrade to theme
  @available(*, deprecated, message: "replaced with theme")
  @Published public var scheme: W3WScheme?

  /// scheme for the bottom sheet
  @Published public var bottomSheetScheme: W3WScheme? = W3WScheme.w3w
  
  /// the view mode - for still / live - perhaps depricated?
  @Published public var viewType = W3WOcrViewType.still
  
  /// the binding to the lock on the import button
  @Published public var lockOnImportButton = true

  /// the binding to the lock on the live/still switch
  @Published public var lockOnLiveSwitch = true

  /// app events of rlogging / analytics
  var events: W3WEvent<W3WAppEvent>?
  
  /// the ocr service
  public var ocr: W3WOcrProtocol?
  
  /// the camera
  @Published public var camera: W3WOcrCamera?

  /// view model for the panel in the bottom sheet
  public var panelViewModel: W3WPanelViewModel
  
  /// indicates if there is a camera session running
  @Published public private(set) var isPreviewing = false
  
  /// indicates if there is a photo being processed
  @Published public private(set) var isTakingPhoto = false

  /// translations for text
  public var translations: W3WTranslationsProtocol
  
  /// we need a boolean to check if we sent an event after the first live scan result
  var firstLiveScanResultHappened = false
  
  /// indicates it the import feature is locked or not
  var importLocked = W3WLive<Bool>(true)
  
  /// indicates it the live scan feature is locked or not
  var liveScanLocked = W3WLive<Bool>(true)

  /// model for the ocr view
  public init(ocr: W3WOcrProtocol,
              theme: W3WLive<W3WTheme?>? = nil,
              importLocked: W3WLive<Bool>,
              liveScanLocked: W3WLive<Bool>,
              isProUser: W3WLive<Bool> = W3WLive<Bool>(true),
              translations: W3WTranslationsProtocol = W3WOcrTranslations(),
              events: W3WEvent<W3WAppEvent>? = W3WEvent<W3WAppEvent>(),
              language: W3WLive<W3WLanguage?>? = nil) {
    self.scheme         = .w3w
    self.theme          = theme ?? W3WLive<W3WTheme?>(.what3words)
    self.translations   = translations
    self.events         = events
    self.importLocked   = importLocked
    self.liveScanLocked = liveScanLocked
    self.ocr = ocr
    
    self.panelViewModel = W3WPanelViewModel(
      mode: .live,
      isProUser: isProUser,
      theme: theme,
      language: language,
      translations: translations
    )
        
    // connect events to functions
    bind()
    
    // bind panelViewModel's output
    subscribe(to: panelViewModel.output) { [weak self] event in
      self?.handle(event: event)
    }
  }
}

// MARK: Bindings
private extension W3WOcrViewModel {
  private func bind() {
    // input events
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
    
    // theme changes (light / dark, etc)
    subscribe(to: theme) { [weak self] theme in
      self?.bottomSheetScheme = theme?.ocrBottomSheetScheme()
    }
    
    // follow the settings for pro mode
    subscribe(to: importLocked) { [weak self] value in
      self?.lockOnImportButton = value
    }
    
    // follow the settings for pro mode
    subscribe(to: liveScanLocked) { [weak self] value in
      self?.lockOnLiveSwitch = value
    }
  }
  
  func handle(event: W3WOcrInputEvent) {
    switch event {
    case .trackCameraMode:
      trackCameraMode()
      
    case .startScanning:
      start()
      
    case .capturePhoto:
      capturePhoto()
      
    case .importPhoto:
      importPhoto()
      
    case .resetScanResult:
      panelViewModel.reset()
      
    case .dismiss:
      output.send(.dismiss)
      stop()
    }
  }
  
  private func handle(event: W3WPanelOutputEvent) {
    switch event {
    case .retry:
      break
      
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
}

// MARK: Actions
private extension W3WOcrViewModel {
  /// start scanning
  func start() {
    guard let camera = W3WOcrCamera.get(camera: .back) else { return }
  
    firstLiveScanResultHappened = false
    camera.start {
      W3WThread.runOnMain { [weak self] in
        self?.camera = camera
      }
    }
    
    subscribe(to: $viewType) { [weak self] value in
      switch value {
      case .video:
        self?.ocr?.autosuggest(video: camera) {  suggestions, error in
          W3WThread.runOnMain { [weak self] in
            self?.autosuggestCompletion(suggestions: suggestions, error: error)
          }
        }
        
      default:
        self?.ocr?.stop {}
        camera.onNewImage = { _ in }
      }
    }
  }
  
  /// Stop the scanning
  func stop() {
    camera?.stop()
    camera = nil
    ocr?.stop {}
  }
}

// MARK: Helpers
private extension W3WOcrViewModel {
  /// do something with the actual scanning result
  func autosuggestCompletion(suggestions: [W3WSuggestion]?, error: Error?) {
    if let error {
      output.send(.error(W3WError.other(error)))
    } else {
      handle(suggestions: suggestions)
    }
  }
  
  /// handle a new scan result
  func handle(suggestions theSuggestions: [W3WSuggestion]?) {
    guard let theSuggestions else { return }
    
    // we are in live scan mode, send all suggestions to the panel
    if viewType == .video {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        panelViewModel.add(suggestions: theSuggestions)
        
        if !firstLiveScanResultHappened {
          firstLiveScanResultHappened = true
          output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrResultLiveScan)))
        }
      }
    }
    
    // send events
    for suggestion in theSuggestions {
      output.send(.detected(suggestion))
    }
  }
    
  func capturePhoto() {
    guard let camera else { return }
    
    isTakingPhoto = true
    camera.captureStillImage { [weak self] image in
      self?.output.send(.captureButton(image))
      self?.isTakingPhoto = false
      
      // Stop the camera
      self?.stop()
    }
    output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrPhotoCapture)))
  }
  
  /// called by UI when the import button is pressed
  func importPhoto() {
    output.send(.importImage)

    if !lockOnImportButton {
      output.send(.analytic(W3WAppEvent(level: .analytic, name: .ocrPhotoImport)))
      
      // Stop the camera
      stop()
    }
  }
  
  /// called by UI when the live capture switch is switched
  func trackCameraMode() {
    let isLiveCaptureOn = viewType == .video
    output.send(.liveCaptureSwitch(isLiveCaptureOn))
    
    guard !lockOnLiveSwitch else { return }
    
    let orcLive: W3WAppEventName = isLiveCaptureOn ? .ocrLiveScanOn : .ocrLiveScanOff
    output.send(.analytic(W3WAppEvent(level: .analytic, name: orcLive)))
  }
  
  
  func makeWordsString(suggestions: [W3WSuggestion]) -> String {
    let retval = suggestions.compactMap { $0.words }
    return "[\"" + retval.joined(separator: "\"],[\"") + "\"]"
  }
}
