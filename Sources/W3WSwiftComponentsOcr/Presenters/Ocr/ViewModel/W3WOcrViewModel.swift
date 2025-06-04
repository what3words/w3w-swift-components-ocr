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


// https://developer.apple.com/documentation/uikit/uiimagepickercontroller
// https://en.proft.me/2023/12/31/avfoundation-capturing-photo-using-avcapturesessio/


public class W3WOcrViewModel: W3WOcrViewModelProtocol, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  public var input = W3WEvent<W3WOcrInputEvent>()
  
  public var output = W3WEvent<W3WOcrOutputEvent>()
  
  public var theme: W3WLive<W3WTheme?>
  
  @Published public var bottomSheetScheme: W3WScheme? = W3WScheme.w3w

  @Published public var viewType = W3WOcrViewType.still
  
  @Published public var stillImage: CGImage?
  
  //@Published public var cameraMode: Bool
  
  //@Published public var spinner: Bool = false
  
  public var ocr: W3WOcrProtocol?
  
  public var camera: W3WOcrCamera?
  
  //public var suggestions = [String:W3WSuggestion]()
  var suggestions = W3WSelectableSuggestions()
  
  //public var selectedSuggestions = Set<String>()

  public var panelViewModel = W3WPanelViewModel()
  
  /// ensures output is stopped, as there can be suggestion stragglers
  //var stopOutput = false
  
  var hasStoppedScanning = false
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle
  
  let scanMessageText = W3WLive<W3WString>("Scan a 3wa text goes here".w3w)

  var selectMode = false
  
  var footerText = W3WLive<W3WString>("")

  var footer: W3WPanelItem?
  
  var footerButtons: [W3WSuggestionsViewControllerFactory]
  
  public var translations: W3WTranslationsProtocol
  
  var selectionButtonsShowing = false

  lazy var selectButton = W3WButtonData(title: "select") { [weak self] in
    self?.selectMode.toggle()
    self?.suggestions.make(selectable: self?.selectMode ?? false)
  }
  
  lazy var selectAllButton = W3WButtonData(title: "select all") { [weak self] in
    self?.suggestions.selectAll()
  }


  public convenience init(ocr: W3WOcrProtocol, camera: W3WOcrCamera, footerButtons: [W3WSuggestionsViewControllerFactory], translations: W3WTranslationsProtocol = W3WOcrTranslations(), theme: W3WTheme? = .what3words) {
    self.init(ocr: ocr, camera: camera, footerButtons: footerButtons, translations: translations, theme: W3WLive<W3WTheme?>(theme))
  }
  
  public init(ocr: W3WOcrProtocol, camera: W3WOcrCamera, footerButtons: [W3WSuggestionsViewControllerFactory], translations: W3WTranslationsProtocol = W3WOcrTranslations(), theme: W3WLive<W3WTheme?>) {
    self.theme = theme
    self.camera = camera //W3WOcrCamera.get(camera: .back)
    self.translations = translations
    self.footerButtons = footerButtons
    
    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
    
    show(scanMessage: true)
    bind(theme: theme)
        
    panelViewModel.input.send(.add(item: .suggestions(suggestions)))
    suggestions.make(selectable: selectMode)
    
    //showSelectionButtons()
    
    viewTypeSwitchEvent(on: viewType == .video)
    
    updateFooterText()
  }

  
  // MARK: Event Handlers
  
  
  func bind(theme: W3WLive<W3WTheme?>) {
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
    
    subscribe(to: suggestions.update) { [weak self] _ in
      self?.updateFooterStatus()
    }
    
    subscribe(to: theme) { [weak self] theme in
      self?.bottomSheetScheme = theme?.ocrBottomSheetScheme()
    }
  }
  
  
  public func handle(suggestions theSuggestions: [W3WSuggestion]?) {
    if let s = theSuggestions {
      show(scanMessage: false)
      suggestions.add(suggestions: s, selected: selectMode ? false : nil)
      updateFooterText()
    }
  }
  
  
  /// start scanning
  public func handle(event: W3WOcrInputEvent) {
    switch event {
      case .image(let image):
        if let i = image {
          output.send(.image(i))
        }
      
      case .stillImage(let image):
        stillImage = image
        
      case .suggestion(let suggestion):
        handle(suggestions: [suggestion])
        
      //case .spinner(let on):
      //  spinner = on
    }
  }


  public func importButtonPressed() {
    output.send(.importImage)
    viewType = .uploaded
  }
  
  
  public func captureButtonPressed() {
    output.send(.captureButton)
  }
  
  
  public func viewTypeSwitchEvent(on: Bool) {
    output.send(.liveCaptureSwitch(on))
  }

  
  public func closeButtonPressed() {
    output.send(.dismiss)
  }

  
  func show(scanMessage: Bool) {
    if scanMessage {
      panelViewModel.input.send(.add(item: .message(scanMessageText)))
    } else {
      panelViewModel.input.send(.remove(item: .message(scanMessageText)))
    }
  }
  
  
  // MARK: Commands
  
    
  func showSelectionButtons() {
    panelViewModel.input.send(.add(item: .buttons([selectButton, selectAllButton])))
  }
  
  
  func hideSelectionButtons() {
    W3WThread.runIn(duration: .seconds(5.0)) { [weak self] in
      if let s = self {
        s.panelViewModel.input.send(.remove(item: .buttons([s.selectButton, s.selectAllButton])))
      }
    }
  }
  
  
  func updateFooterStatus() {
    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
    
    if suggestions.selectedCount() > 0 {
      panelViewModel.input.send(.footer(item: footer))
    } else {
      panelViewModel.input.send(.footer(item: nil))
    }

    if suggestions.count() > 0 && !selectionButtonsShowing {
      selectionButtonsShowing = true
      showSelectionButtons()
    }
    
    if suggestions.count() == 0 && selectionButtonsShowing {
      panelViewModel.input.send(.footer(item: nil))
      hideSelectionButtons()
      selectionButtonsShowing = false
    }
    
    updateFooterText()
  }

  
  func updateFooterText() {
    footerText.send("\(suggestions.selectedCount()) \(translations.get(id: "selected").w3w)".w3w)
  }
  
  
  // MARK: Untility
  
  
  func convert(footerButtons: [W3WSuggestionsViewControllerFactory]) -> [W3WButtonData] {
    var buttons = [W3WButtonData]()

    for footerButton in footerButtons {
      if !footerButton.onlyForSingleSuggestion || (footerButton.onlyForSingleSuggestion && suggestions.selectedCount() == 1) {
        buttons.append(W3WButtonData(icon: footerButton.icon, title: footerButton.title, onTap: { [weak self] in
          if let s = self {
            self?.output.send(.footerButton(footerButton, suggestions: s.suggestions.selectedSuggestions))
          }
        }))
      }
    }
    
    return buttons
  }

  
  
}
