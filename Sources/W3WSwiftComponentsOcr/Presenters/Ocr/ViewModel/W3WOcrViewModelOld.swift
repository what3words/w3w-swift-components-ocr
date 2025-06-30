////
////  W3WOcrViewModel.swift
////  w3w-swift-components-ocr
////
////  Created by Dave Duprey on 30/04/2025.
////
//
//
//import SwiftUI
//import W3WSwiftCore
//import W3WSwiftThemes
//import W3WSwiftPresenters
//import W3WSwiftAppEvents
//
//
//// https://developer.apple.com/documentation/uikit/uiimagepickercontroller
//// https://en.proft.me/2023/12/31/avfoundation-capturing-photo-using-avcapturesessio/
//
//
//public class W3WOcrViewModel2: W3WOcrViewModelProtocol, W3WEventSubscriberProtocol {
//  public var subscriptions = W3WEventsSubscriptions()
//  
//  public var input = W3WEvent<W3WOcrInputEvent>()
//  
//  public var output = W3WEvent<W3WOcrOutputEvent>()
//  
//  public var theme: W3WLive<W3WTheme?>
//
//  @available(*, deprecated, message: "replaced with theme")
//  @Published public var scheme: W3WScheme?
//
//  @Published public var bottomSheetScheme: W3WScheme? = W3WScheme.w3w
//
//  var events: W3WEvent<W3WAppEvent>
//  
//  public var ocr: W3WOcrProtocol?
//  
//  public var camera: W3WOcrCamera?
//  
//  //public var suggestions = [String:W3WSuggestion]()
//  var suggestions = W3WSelectableSuggestions()
//  
//  public var selectedSuggestions = Set<String>()
//
//  public var panelViewModel = W3WPanelViewModel()
//  
//  @Published public var viewType = W3WOcrViewType.video
//  
//  //@Published public var cameraMode: Bool
//  
////  @Published public var stillImage: CGImage?
//  
////  @Published public var spinner: Bool = false
//  
//  /// ensures output is stopped, as there can be suggestion stragglers
//  //var stopOutput = false
//  
//  var hasStoppedScanning = false
//  /// indicates it's current state: scanning/stopped
//  public var state = W3WOcrState.idle
//  
//  lazy var scanMessageText = W3WLive<W3WString>(translations.get(id: "ocr_scan_3wa").w3w)
//
//  var selectMode = false
//  
//  var footerText = W3WLive<W3WString>("")
//
//  var footer: W3WPanelItem?
//  
//  var footerButtons: [W3WSuggestionsViewAction]
//
//  public var translations: W3WTranslationsProtocol
//
//  var selectionButtonsShowing = false
//
//  // Buttons
//  
//  lazy var selectButton = W3WButtonData(title: translations.get(id: "ocr_selectButton")) { [weak self] in
//    self?.selectMode.toggle()
//    self?.suggestions.make(selectable: self?.selectMode ?? false)
//  }
//  
//  lazy var selectAllButton = W3WButtonData(title: translations.get(id: "ocr_selectAllButton")) { [weak self] in
//    self?.selectMode = true
//    self?.suggestions.selectAll()
//  }
//
//  
//  
//  public init(ocr: W3WOcrProtocol, theme: W3WLive<W3WTheme?>? = nil, footerButtons: [W3WSuggestionsViewAction] = [], translations: W3WTranslationsProtocol = W3WOcrTranslations(), events: W3WEvent<W3WAppEvent> = W3WEvent<W3WAppEvent>()) {
//    self.scheme        = .w3w
//    self.theme         = theme ?? W3WLive<W3WTheme?>(.what3words)
//    self.camera        = W3WOcrCamera.get(camera: .back)
//    self.translations  = translations
//    self.footerButtons = footerButtons
//    self.events        = events
//
//    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
//
//    set(ocr: ocr)
//    
//    show(scanMessage: true)
//    
//    bind()
//    
//    panelViewModel.input.send(.add(item: .suggestions(suggestions)))
//    
//    start()
//    
//    updateFooterText()
//    
//    // DEBUG
//    handle(suggestions: [W3WBaseSuggestion(words: "fancy.duck.cloud")])
//  }
//  
//  
//  
//  /// assign an OCR engine that conforms to W3WOcrProtocol to this component
//  /// - Parameters:
//  ///     - ocr: the W3WOcrProtocol conforming OCR engine
//  public func set(ocr: W3WOcrProtocol?) {
//    self.ocr = ocr
//    
//    if camera == nil {
//      self.camera = W3WOcrCamera.get(camera: .back)
//      self.camera?.onCameraStarted = { [weak self, weak camera] in
//        guard let self, let camera else {
//          return
//        }
//        //self.onCameraStarted()
//      }
//    }
//  }
//  
//  
////  public func set(image: CGImage) {
////    self.stillImage = image
////  }
//  
//  
//  func bind() {
//    subscribe(to: input) { [weak self] event in
//      self?.handle(event: event)
//    }
//    
//    subscribe(to: suggestions.update) { [weak self] _ in
//      self?.updateFooterStatus()
//      print("update", self?.suggestions.count())
//    }
//    
//    subscribe(to: theme) { [weak self] theme in
//      self?.bottomSheetScheme = theme?.ocrBottomSheetScheme()
//    }
//    
//    suggestions.singleSelection = { [weak self] selection in
//      self?.output.send(.selected(selection))
//    }
//  }
//  
//  
//  public func importButtonPressed() {
//    output.send(.importImage)
//    viewType = .uploaded
//  }
//  
//  
//  public func captureButtonPressed() {
//    output.send(.captureButton)
//  }
//  
//  
//  public func viewTypeSwitchEvent(on: Bool) {
//    output.send(.liveCaptureSwitch(on))
//  }
//
//  
//  public func closeButtonPressed() {
//    output.send(.dismiss)
//  }
//
//  
//  func show(scanMessage: Bool) {
//    if scanMessage {
//      panelViewModel.input.send(.add(item: .heading(scanMessageText)))
//    } else {
//      panelViewModel.input.send(.remove(item: .heading(scanMessageText)))
//    }
//  }
//  
//  
//  // MARK: Commands
//  
//    
//  func showSelectionButtons() {
//    panelViewModel.input.send(.add(item: .buttons([selectButton, selectAllButton])))
//  }
//  
//  
//  func hideSelectionButtons() {
//    W3WThread.runIn(duration: .seconds(5.0)) { [weak self] in
//      if let s = self {
//        s.panelViewModel.input.send(.remove(item: .buttons([s.selectButton, s.selectAllButton])))
//      }
//    }
//  }
//  
//  
//  func updateFooterStatus() {
//    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
//    
//    if suggestions.selectedCount() > 0 {
//      panelViewModel.input.send(.footer(item: footer))
//    } else {
//      panelViewModel.input.send(.footer(item: nil))
//    }
//
//    if suggestions.count() > 0 && !selectionButtonsShowing {
//      selectionButtonsShowing = true
//      showSelectionButtons()
//    }
//    
//    if suggestions.count() == 0 && selectionButtonsShowing {
//      panelViewModel.input.send(.footer(item: nil))
//      hideSelectionButtons()
//      selectionButtonsShowing = false
//    }
//    
//    updateFooterText()
//  }
//
//  
//  func updateFooterText() {
//    footerText.send("\(suggestions.selectedCount()) \(translations.get(id: "ocr_w3wa_selected_number"))".w3w)
//  }
//  
//
//  /// start scanning
//  public func start() {
//    //stopOutput = false
//    hasStoppedScanning = false
//    if let c = camera, let o = ocr {
//      state = .detecting
//      c.start()
//      
//      o.autosuggest(video: c) { [weak self] suggestions, error in
//        self?.ocrResults(suggestions: suggestions, error: error == nil ? nil : W3WError.other(error))
//      }
//    }
//  }
//  
//  
//  public func ocrResults(suggestions: [W3WSuggestion]?, error: W3WError?) {
//    //guard let self else { return }
//    if self == nil {
//      print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
//      
//    } else if let e = error {
//      output.send(.error(e))
//      
//    } else { //if stopOutput == false {
//      handle(suggestions: suggestions)
//    }
//  }
//  
//  
//  func stop() {
//    //stopOutput = true
//    hasStoppedScanning = true
//    
//    if let c = camera, let o = ocr {
//      state = .idle
//      c.stop()
//    }
//  }
//  
//  
////  func add(suggestion: W3WSuggestion) {
////    show(scanMessage: false)
////  }
//  
//  
//  // MARK: Event Handlers
//  
//  
//  public func handle(suggestions theSuggestions: [W3WSuggestion]?) {
//    if let s = theSuggestions {
//      show(scanMessage: false)
//      suggestions.add(suggestions: s, selected: false)
//    }
//  }
//  
//  
//  /// input events
//  public func handle(event: W3WOcrInputEvent) {
//    switch event {
//      case .startScanning:
//        start()
//      case .stopScanning:
//        stop()
//    }
//  }
//
//
//  // MARK: Untility
//  
//  
//  func convert(footerButtons: [W3WSuggestionsViewControllerFactory]) -> [W3WButtonData] {
//    var buttons = [W3WButtonData]()
//
//    for footerButton in footerButtons {
//      if !footerButton.onlyForSingleSuggestion || (footerButton.onlyForSingleSuggestion && suggestions.selectedCount() == 1) {
//        buttons.append(W3WButtonData(icon: footerButton.icon, title: footerButton.title, onTap: { [weak self] in
//          if let s = self {
//            self?.output.send(.footerButton(footerButton, suggestions: s.suggestions.selectedSuggestions))
//          }
//        }))
//      }
//    }
//    
//    return buttons
//  }
//
//  
//  /// Handle the first ocr suggestion, if it's not duplicated then insert it on top of the bottom sheet.
//  /// - Parameters:
//  ///     - suggestions: the suggestions that was found
////  open func handleNewSuggestions(_ suggestions: [W3WOcrSuggestion]) {
////    guard let suggestion = suggestions.first,
////          let threeWordAddress = suggestion.words else {
////      return
////    }
////
////    state = .scanning
////    onReceiveRawSuggestions([suggestion])
////
////    // Check for inserting or moving
////    if uniqueOcrSuggestions.contains(threeWordAddress) {
////      handleDuplicatedSuggestion(suggestion)
////      state = .scanned
////      return
////    } else {
////      uniqueOcrSuggestions.insert(threeWordAddress)
////    }
////
////    // Perform autosuggest just when there is w3w
////    if let w3w = w3w {
////      autosuggest(w3w: w3w, text: threeWordAddress) { [weak self] result in
////        DispatchQueue.main.async {
////          switch result {
////          case .success(let autoSuggestion):
////            let result = autoSuggestion ?? suggestion
////            guard let words = result.words else {
////              return
////            }
////            self?.state = .scanned
////            if words == threeWordAddress {
////              self?.insertMoreSuggestions([result])
////              self?.onSuggestions([result])
////            } else {
////              // Handle when autosuggest returns different word with the original ocr suggestion
////              if self?.uniqueOcrSuggestions.contains(words) ?? false {
////                return
////              }
////              self?.uniqueOcrSuggestions.insert(words)
////              self?.insertMoreSuggestions([result])
////              self?.onSuggestions([result])
////            }
////          case .failure(let error):
////            // Ignore the autosuggest error and display what the ocr provides
////            self?.insertMoreSuggestions([suggestion])
////            self?.onSuggestions([suggestion])
////            print("autosuggest error: \((error as NSError).debugDescription)")
////          }
////        }
////      }
////      return
////    }
////    // Just display what the ocr provides
////    state = .scanned
////    insertMoreSuggestions([suggestion])
////    onSuggestions([suggestion])
////  }
//
//  
//}
