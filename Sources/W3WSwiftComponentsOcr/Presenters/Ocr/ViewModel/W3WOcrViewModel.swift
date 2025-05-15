//
//  W3WOcrViewModel.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//


import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes


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
  
  @Published public var viewType = W3WOcrViewType.video
  
  //@Published public var cameraMode: Bool
  
  @Published public var stillImage: CGImage?
  
  @Published public var spinner: Bool = false
  
  /// ensures output is stopped, as there can be suggestion stragglers
  //var stopOutput = false
  
  var hasStoppedScanning = false
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle
  
  let scanMessageText = W3WLive<W3WString>("Scan a 3wa text goes here".w3w)

  
  public init(ocr: W3WOcrProtocol, scheme: W3WScheme? = nil) {
    self.scheme = scheme
    self.camera = W3WOcrCamera.get(camera: .back)
    //self.cameraMode = false
    
    set(ocr: ocr)
    
    show(scanMessage: true)
    
    bind()
    
    panelViewModel.input.send(.add(item: .suggestions(suggestions)))
    
    viewTypeSwitchEvent(on: viewType == .video)
  }
  
  
  
  /// assign an OCR engine that conforms to W3WOcrProtocol to this component
  /// - Parameters:
  ///     - ocr: the W3WOcrProtocol conforming OCR engine
  public func set(ocr: W3WOcrProtocol?) {
    self.ocr = ocr
    
    if camera == nil {
      self.camera = W3WOcrCamera.get(camera: .back)
      self.camera?.onCameraStarted = { [weak self, weak camera] in
        guard let self, let camera else {
          return
        }
        //self.onCameraStarted()
      }
    }
  }
  
  
  public func set(image: CGImage) {
    self.stillImage = image
  }
  
  
  func bind() {
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
  }
  
  
  public func importButtonPressed() {
    output.send(.importImage)
    viewType = .uploaded
  }
  
  
  public func captureButtonPressed() {
    print(#function)
  }
  
  
  public func viewTypeSwitchEvent(on: Bool) {
    viewType = on ? .video : .still
    
    if viewType == .video {
      start()
    } else {
      stop()
    }
  }


  
  /// start scanning
  public func start() {
    //stopOutput = false
    hasStoppedScanning = false
    if let c = camera, let o = ocr {
      state = .detecting
      c.start()
      
      o.autosuggest(video: c) { [weak self] suggestions, error in
        self?.ocrResults(suggestions: suggestions, error: error == nil ? nil : W3WError.other(error))
      }
    }
  }
  
  
  public func ocrResults(suggestions: [W3WSuggestion]?, error: W3WError?) {
    //guard let self else { return }
    if self == nil {
      print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
      
    } else if let e = error {
      output.send(.error(e))
      
    } else { //if stopOutput == false {
      handle(suggestions: suggestions)
    }
  }
  
  
  func stop() {
    //stopOutput = true
    hasStoppedScanning = true
    
    if let c = camera, let o = ocr {
      state = .idle
      c.stop()
    }
  }
  
  
//  func add(suggestion: W3WSuggestion) {
//    show(scanMessage: false)
//  }
  
  
  func show(scanMessage: Bool) {
    if scanMessage {
      panelViewModel.input.send(.add(item: .message(scanMessageText)))
    } else {
      panelViewModel.input.send(.remove(item: .message(scanMessageText)))
    }
  }
  
  
  
  // MARK: Event Handlers
  
  
  public func handle(suggestions theSuggestions: [W3WSuggestion]?) {
    if let s = theSuggestions {
      show(scanMessage: false)
      suggestions.add(suggestions: s, selected: false)
    }
  }
  
  
  /// start scanning
  public func handle(event: W3WOcrInputEvent) {
    //switch event {
      //case .dismiss:
      //  stop()
        
      //case .displayMode(let mode):
    //}
  }



  
  /// Handle the first ocr suggestion, if it's not duplicated then insert it on top of the bottom sheet.
  /// - Parameters:
  ///     - suggestions: the suggestions that was found
//  open func handleNewSuggestions(_ suggestions: [W3WOcrSuggestion]) {
//    guard let suggestion = suggestions.first,
//          let threeWordAddress = suggestion.words else {
//      return
//    }
//
//    state = .scanning
//    onReceiveRawSuggestions([suggestion])
//
//    // Check for inserting or moving
//    if uniqueOcrSuggestions.contains(threeWordAddress) {
//      handleDuplicatedSuggestion(suggestion)
//      state = .scanned
//      return
//    } else {
//      uniqueOcrSuggestions.insert(threeWordAddress)
//    }
//
//    // Perform autosuggest just when there is w3w
//    if let w3w = w3w {
//      autosuggest(w3w: w3w, text: threeWordAddress) { [weak self] result in
//        DispatchQueue.main.async {
//          switch result {
//          case .success(let autoSuggestion):
//            let result = autoSuggestion ?? suggestion
//            guard let words = result.words else {
//              return
//            }
//            self?.state = .scanned
//            if words == threeWordAddress {
//              self?.insertMoreSuggestions([result])
//              self?.onSuggestions([result])
//            } else {
//              // Handle when autosuggest returns different word with the original ocr suggestion
//              if self?.uniqueOcrSuggestions.contains(words) ?? false {
//                return
//              }
//              self?.uniqueOcrSuggestions.insert(words)
//              self?.insertMoreSuggestions([result])
//              self?.onSuggestions([result])
//            }
//          case .failure(let error):
//            // Ignore the autosuggest error and display what the ocr provides
//            self?.insertMoreSuggestions([suggestion])
//            self?.onSuggestions([suggestion])
//            print("autosuggest error: \((error as NSError).debugDescription)")
//          }
//        }
//      }
//      return
//    }
//    // Just display what the ocr provides
//    state = .scanned
//    insertMoreSuggestions([suggestion])
//    onSuggestions([suggestion])
//  }

  
}
