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
  
  @Published public var scheme: W3WScheme?

  public var ocr: W3WOcrProtocol?
  
  public var camera: W3WOcrCamera?
  
  //public var suggestions = [String:W3WSuggestion]()
  var suggestions = W3WSelectableSuggestions()
  
  public var selectedSuggestions = Set<String>()

  public var panelViewModel = W3WPanelViewModel()
  
  @Published public var viewType = W3WOcrViewType.still
  
  //@Published public var cameraMode: Bool
  
  @Published public var stillImage: CGImage?
  
  //@Published public var spinner: Bool = false
  
  /// ensures output is stopped, as there can be suggestion stragglers
  //var stopOutput = false
  
  var hasStoppedScanning = false
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle
  
  let scanMessageText = W3WLive<W3WString>("Scan a 3wa text goes here".w3w)

  var selectMode = false
  
  var footerText = W3WLive<W3WString>("")

  var footer: W3WPanelItem?
  
  var translations: W3WTranslationsProtocol?
  
//  lazy var saveButton = W3WButtonData(title: translations?.get(id: "save_button") ?? "save", onTap: { [weak self] in
//    self?.output.send(.saveButton(self?.suggestions.selectedSuggestions ?? []))
//  })
//  
//  lazy var shareButton = W3WButtonData(title: translations?.get(id: "share_button") ?? "share", onTap: { [weak self] in
//    self?.output.send(.shareButton(self?.suggestions.selectedSuggestions ?? []))
//  })
//
//  lazy var mapButton = W3WButtonData(title: translations?.get(id: "map_button") ?? "map", onTap: { [weak self] in
//    self?.output.send(.mapButton(self?.suggestions.selectedSuggestions ?? []))
//  })

  
  public init(ocr: W3WOcrProtocol, camera: W3WOcrCamera, footerButtons: [W3WSuggestionsViewControllerFactory], translations: W3WTranslationsProtocol? = nil, scheme: W3WScheme? = nil) {
    self.scheme = scheme
    self.camera = camera //W3WOcrCamera.get(camera: .back)
    self.translations = translations
    
    footer = .buttons(convert(footerButtons: footerButtons), text: footerText)
    
    show(scanMessage: true)
    bind()
    
    panelViewModel.input.send(.add(item: .suggestions(suggestions)))
    suggestions.make(selectable: selectMode)
    
    showSelectionButtons()
    
    viewTypeSwitchEvent(on: viewType == .video)
    
    updateFooterText()
  }

  
  // MARK: Event Handlers
  
  
  func bind() {
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
    
    subscribe(to: suggestions.update) { [weak self] _ in
      self?.updateFooterStatus()
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


  
  func show(scanMessage: Bool) {
    if scanMessage {
      panelViewModel.input.send(.add(item: .message(scanMessageText)))
    } else {
      panelViewModel.input.send(.remove(item: .message(scanMessageText)))
    }
  }
  
  
  // MARK: Commands
  
    
  func showSelectionButtons() {
    let selectButton = W3WButtonData(title: "select") { [weak self] in
      self?.selectMode.toggle()
      self?.suggestions.make(selectable: self?.selectMode ?? false)
      //self?.updateFooterStatus()
    }
    
    let selectAllButton = W3WButtonData(title: "select all") { [weak self] in
      self?.suggestions.selectAll()
      //self?.updateFooterStatus()
    }
    
    panelViewModel.input.send(.add(item: .buttons([selectButton, selectAllButton])))
  }
  
  
  func updateFooterStatus() {
    if suggestions.selectedCount() > 0 {
      panelViewModel.input.send(.footer(item: footer))
    } else {
      panelViewModel.input.send(.footer(item: nil))
    }
    
    updateFooterText()
  }

  
  func updateFooterText() {
    footerText.send("\(suggestions.selectedCount()) \(translations?.get(id: "selected") ?? "selected")".w3w)
  }
  
  
  // MARK: Untility
  
  
  func convert(footerButtons: [W3WSuggestionsViewControllerFactory]) -> [W3WButtonData] {
    var buttons = [W3WButtonData]()

    for footerButton in footerButtons {
      buttons.append(W3WButtonData(icon: footerButton.icon, title: footerButton.title, onTap: { [weak self] in
        if let s = self {
          self?.output.send(.footerButton(footerButton, suggestions: s.suggestions.selectedSuggestions))
        }
      }))
    }
    
    return buttons
  }

  
  
}
