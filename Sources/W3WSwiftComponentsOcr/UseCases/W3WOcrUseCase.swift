//
//  W3WOcrImagePickerUseCase.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 07/05/2025.
//

import CoreGraphics
import W3WSwiftCore
import W3WSwiftPresenters


open class W3WOcrUseCase: W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  public var ocrOutput: W3WEvent<W3WOcrOutputEvent>
  
  public var ocrInput: W3WEvent<W3WOcrInputEvent>
  
  public var pickerOutput: W3WEvent<W3WImagePickerOutputEvent>
  
  public var pickerInput: W3WEvent<W3WImagePickerInputEvent>
  
  public var ocr: W3WOcrProtocol?

  public var camera: W3WOcrCamera
  
  var cameraRunning = false
  
  lazy var liveFeed = false
  
  var importActive = false
  
  var lastSuggestions = [W3WSuggestion]()

  //weak var ocrViewModel: (any W3WOcrViewModelProtocol)?
  
  var buttons: [W3WSuggestionsViewControllerFactory] = []
  
  
  public init(buttons: [W3WSuggestionsViewControllerFactory] = [], camera: W3WOcrCamera, ocr: W3WOcrProtocol?, ocrOutput: W3WEvent<W3WOcrOutputEvent>, ocrInput: W3WEvent<W3WOcrInputEvent>, pickerOutput: W3WEvent<W3WImagePickerOutputEvent>, pickerInput: W3WEvent<W3WImagePickerInputEvent>) { //, ocrViewModel: any W3WOcrViewModelProtocol) {
    self.ocr    = ocr
    self.camera  = camera
    self.buttons  = buttons
    self.ocrInput  = ocrInput
    self.ocrOutput  = ocrOutput
    self.pickerInput = pickerInput
    self.pickerOutput = pickerOutput

    //self.ocrViewModel = ocrViewModel
    bind()
    
    ocr?.autosuggest(video: camera) { [weak self] suggestions, error in
      self?.autosuggestCompletion(suggestions: suggestions, error: error == nil ? nil : W3WError.message(error?.description ?? "unknown"))
      //self?.handle(suggestions: suggestions)
      //if let e = error {
      //  self?.handle(error: W3WError.message(error?.description ?? "unknown"))
      //}
    }
    
    startCamera()
  }
  
  
  // MARK: Event handlers
  
  
  func bind() {
    subscribe(to: pickerOutput) { [weak self] event in
      self?.handle(pickerOutputEvent: event)
    }
    
    subscribe(to: ocrOutput) { [weak self] event in
      self?.handle(ocrOutputEvent: event)
    }
  }
    
  
  open func handle(pickerOutputEvent: W3WImagePickerOutputEvent) {
    switch pickerOutputEvent {
      case .image(let image):
        importActive = true
        ocrInput.send(.stillImage(image))
        process(image: image)

      case .dismiss:
        print("dismiss", #file, #function)
        
      case .error(let error):
        print(error, #file, #function)
    }
  }
  
  
  open func handle(ocrOutputEvent: W3WOcrOutputEvent) {
    switch ocrOutputEvent {
      case .error(let error):
        print(error, #file, #function)
        
      case .importImage:
        print("import image button tapped", #file, #function)
        stopCamera()

      case .captureButton:
        handle(suggestions: lastSuggestions)

      case .liveCaptureSwitch(let video):
        print("live video", video, #file, #function)
        startCamera()
        liveFeed = video

      case .image(let image):
        process(image: image)

      case .footerButton(let factory, suggestions: let suggestions):
        print("footer", #file, #function)
        //showSuggestionView(factory: factory, suggestions: suggestions)
        
      case .dismiss:
        stopCamera()
        ocr?.stop { }
        
//      case .saveButton(let suggestions):
//        print("SAVE:", suggestions)
//
//      case .shareButton(let suggestions):
//        print("SHARE", suggestions)
//
//      case .mapButton(let suggestions):
//        print("MAP", suggestions)
    }
  }
  
  
  func handle(error: W3WError?) {
    if let e = error {
      print(error)
    }
  }
  
  
  func process(image: CGImage?) {
    if let i = image {
      print("IMAGE:", "\(i.width), \(i.height)", #file, #function)
      ocr?.autosuggest(image: i, info: { _ in }) { [weak self] suggestions, error in
        self?.autosuggestCompletion(suggestions: suggestions, error: error == nil ? nil : W3WError.message(error?.description ?? "unknown"))
      }
    }
  }
  

  func autosuggestCompletion(suggestions: [W3WSuggestion], error: W3WError?) {
    lastSuggestions = suggestions
    
    if liveFeed {
      handle(suggestions: suggestions)
      if let e = error {
        handle(error: W3WError.message(error?.description ?? "unknown"))
      }
      
    } else if importActive {
      importActive = false
      handle(suggestions: suggestions)
    }
  }
  
  
  func handle(suggestions: [W3WSuggestion]) {
    for suggestion in suggestions {
      ocrInput.send(.suggestion(suggestion))
    }
  }

  
//  func handle(event: W3WImagePickerOutputEvent) {
//    switch event {
//        
//      case .image(let image):
//        handle(image: image)
//      
//      case .dismiss:
//        print("dismiss goes here")
//        
//      case .error(let error):
//        print(error)
//    }
//  }
  
  
  func handle(image: CGImage) {
//    ocrViewModel?.set(image: image)
//    
//    ocr?.autosuggest(image: image, info: { _ in }) { [weak self] suggestions, error in
//      self?.ocrViewModel?.ocrResults(suggestions: suggestions, error: error == nil ? nil : W3WError.other(error))
//      ////guard let self else { return }
//      //if self == nil {
//      //  print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
//      //
//      //} else if let e = error {
//      //  DispatchQueue.main.async {
//      //    //self.handleOcrError(e)
//      //    //self?.pickerOutput.send(.error(W3WError.message(e.description)))
//      //    self?.ocrViewModel?.output.send(.error(W3WError.message(e.description)))
//      //  }
//      //} else {
//      //  //DispatchQueue.main.async {
//      //    self?.ocrViewModel?.handle(suggestions: suggestions)
//      //  //}
//      //}
//    }
  }
  
  
  // MARK: Actions
  
  
  func startCamera() {
    if !cameraRunning {
      cameraRunning = true
      camera.start()
    }
  }
  
  
  func stopCamera() {
    cameraRunning = false
    camera.stop()
  }
  
  
}
