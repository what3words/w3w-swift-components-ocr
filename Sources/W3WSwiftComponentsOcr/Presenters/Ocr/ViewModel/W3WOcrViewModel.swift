//
//  W3WOcrViewModel.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//


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
  
  /// the ocr service crop rect
  public let ocrCropRect = W3WEvent<CGRect>()
  
  /// the camera
  public var camera: W3WOcrCamera?
  
  /// the suggestions that ocr collects
  public var suggestions = W3WSelectableSuggestions()

  /// view model for the panel in the bottom sheet
  public var panelViewModel: W3WPanelViewModel
  
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle
  
  /// indicates if there is a photo being processed
  @Published public var isTakingPhoto = false
  
  /// intro message for scanning
  lazy var scanMessageText = W3WLive<W3WString>(translations.get(id: "ocr_scan_3wa").w3w)

  /// translations for text
  public var translations: W3WTranslationsProtocol

  /// logic for the bottom sheet
  var bottomSheetLogic: W3WBottomSheetLogicProtocol

  /// the most recent suggestions found - for "still" mode
  var lastSuggestions = [W3WSuggestion]()
  
  /// we need a boolean to check if we sent an event after the first live scan result
  var firstLiveScanResultHappened = false
  
  /// indicates it the import feature is locked or not
  var importLocked = W3WLive<Bool>(true)
  
  /// indicates it the live scan feature is locked or not
  var liveScanLocked = W3WLive<Bool>(true)

  /// allows the suggestions to be selected into a list
  var selectableSuggestionList = W3WLive<Bool>(true)
  
  
  /// model for the ocr view
  public init(ocr: W3WOcrProtocol,
              theme: W3WLive<W3WTheme?>? = nil,
              footerButtons: [W3WSuggestionsViewAction] = [],
              importLocked: W3WLive<Bool>,
              liveScanLocked: W3WLive<Bool>,
              selectableSuggestionList: W3WLive<Bool> = W3WLive<Bool>(true),
              translations: W3WTranslationsProtocol = W3WOcrTranslations(),
              events: W3WEvent<W3WAppEvent>? = W3WEvent<W3WAppEvent>(),
              language: W3WLive<W3WLanguage?>? = nil) {
    self.scheme         = .w3w
    self.theme          = theme ?? W3WLive<W3WTheme?>(.what3words)
    self.camera         = W3WOcrCamera.get(camera: .back)
    self.translations   = translations
    self.events         = events
    self.importLocked   = importLocked
    self.liveScanLocked = liveScanLocked
    self.ocr = ocr
    self.panelViewModel = W3WPanelViewModel(language: language, translations: translations)
    // make the manager fro the bottom sheet
    self.bottomSheetLogic = W3WBottomSheetLogicInsanity(suggestions: suggestions, panelViewModel: panelViewModel, footerButtons: footerButtons, translations: translations, viewType: .video, selectableSuggestionList: selectableSuggestionList)
    
    // show the default message at the bottom
    show(scanMessage: true)
    
    // connect events to functions
    bind()
    
    // start the OCR process
    start()
  }
  

  /// connect the events to functions
  func bind() {
    // input events
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
    
    // theme changes (light / dark, etc)
    subscribe(to: theme) { [weak self] theme in
      self?.bottomSheetScheme = theme?.ocrBottomSheetScheme()
    }
    
    // when the user selects a single address
    suggestions.singleSelection = { [weak self] selection in
      // Stop scanning as the selection will be handled externally after this view is dismissed
      self?.stop()
      self?.output.send(.selected(selection))
    }
    
    // when a button is tapped on the bottom panel
    bottomSheetLogic.onButton = { [weak self] button, suggestions in
      self?.output.send(.footerButton(button, suggestions: suggestions))
      self?.output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrFooterButton, parameters: ["button": .text(button.title), "words": .text(self?.makeWordsString(suggestions: suggestions))])))
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

    // follow the settings for pro mode
    subscribe(to: importLocked) { [weak self] value in
      self?.lockOnImportButton = value
    }
    
    // follow the settings for pro mode
    subscribe(to: liveScanLocked) { [weak self] value in
      self?.lockOnLiveSwitch = value
    }
  }
  
  
  /// called by UI when the import button is pressed
  public func importButtonPressed() {
    output.send(.importImage)

    if !lockOnImportButton {
      output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrPhotoImport)))
    }
  }
  
  
  /// called by UI when the capture button is pressed
  public func captureButtonPressed() {
    isTakingPhoto = true
    
    camera?.captureStillImage() { [weak self] image in
      self?.output.send(.captureButton(image))
      self?.isTakingPhoto = false
    }
    
    if viewType == .still {
      bottomSheetLogic.add(suggestions: lastSuggestions)
    }

    output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrPhotoCapture)))
  }
  
  
  /// called by UI when the live capture switch is switched
  public func viewTypeSwitchEvent(on: Bool) {
    if on { // if we pause the camera on still capture, the unpause (see above)
      //camera?.unpause()
    }
    
    output.send(.liveCaptureSwitch(on))
    
    if !lockOnLiveSwitch {
      output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrLiveScan, parameters: ["on": .boolean(on)])))
      if on {
        output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrLiveScanOn)))
      } else {
        output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrLiveScanOff)))
      }
    }
  }

  
  /// called by UI when the close button is pressed
  public func closeButtonPressed() {
    output.send(.dismiss)
    stop()
  }

  
  /// shows/hides the inital scan message
  func show(scanMessage: Bool) {
    if scanMessage {
      //bottomSheetLogic.panelViewModel.input.send(.add(item: .heading(scanMessageText)))
      panelViewModel.input.send(.add(item: .heading(scanMessageText)))
    } else {
      //bottomSheetLogic.panelViewModel.input.send(.remove(item: .heading(scanMessageText)))
      panelViewModel.input.send(.remove(item: .heading(scanMessageText)))
    }
  }
  
  
  // MARK: Commands
  
    
  /// start scanning
  public func start() {
    guard let camera, let ocr else { return }
    guard state == .idle else { return }
    
    state = .detecting
    
    // Maybe we need a better check if there is a paused session
    if camera.session != nil {
      camera.unpause()
      return
    }

    firstLiveScanResultHappened = false
    camera.start()
    
    ocr.autosuggest(video: camera) { [weak self] suggestions, error in
      guard let self else { return }
      autosuggestCompletion(suggestions: suggestions, error: error)
      
      if !firstLiveScanResultHappened {
        firstLiveScanResultHappened = true
        output.send(.analytic(W3WAppEvent(type: Self.self, level: .analytic, name: .ocrResultLiveScan)))
      }
    }
  }
  
  
  /// do something with the actual scanning result
  public func autosuggestCompletion(suggestions: [W3WSuggestion]?, error: Error?) {
    if let error {
      output.send(.error(W3WError.other(error)))
    } else {
      handle(suggestions: suggestions)
    }
  }
  

  /// pause the scanning
  func pause() {
    if let camera {
      state = .idle
      camera.pause()
    }
  }
  
  
  /// Stop the scanning
  func stop() {
    if let camera {
      state = .idle
      camera.stop()
    }
  }
  
    
  // MARK: Event Handlers
  
  
  /// handle a new scan result
  public func handle(suggestions theSuggestions: [W3WSuggestion]?) {
    guard let theSuggestions else { return }
    
    // remember the most recent results for "still" mode
    lastSuggestions = theSuggestions
    
    // we are in live scan mode, send all suggestions to the panel
    if viewType == .video {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.bottomSheetLogic.add(suggestions: theSuggestions)
      }
    }
    
    // send events
    for suggestion in theSuggestions {
      output.send(.detected(suggestion))
    }
    
    // remove text if suggestions are available
    if bottomSheetLogic.suggestions.count() > 0 {
      show(scanMessage: false)
    }
  }
  
  
  /// input events
  public func handle(event: W3WOcrInputEvent) {
    switch event {
      case .startScanning:
        start()
      case .pauseScanning:
        pause()
    }
  }
  
  
  // MARK: Utility


  func makeWordsString(suggestions: [W3WSuggestion]) -> String {
    let retval = suggestions.compactMap { $0.words }
    return retval.joined(separator: ",")
  }

}
