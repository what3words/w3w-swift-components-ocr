//
//  W3WOcrCoordinator.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 15/05/2025.
//


import W3WSwiftCore
import W3WSwiftCoordinator
import W3WSwiftPresenters


public class W3WOcrCoordinator: W3WViewCoordinator, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  let ocrViewModel: W3WOcrViewModel
  
  let ocrUseCase: W3WOcrUseCase
  
  let pickerViewModel = W3WImagePickerViewModel()

  var camera: W3WOcrCamera
  
  
  public init(ocr: W3WOcrProtocol, camera: W3WOcrCamera, footerButtons: [W3WSuggestionsViewControllerFactory]) {
    self.camera = camera
    
    ocrViewModel = W3WOcrViewModel(ocr: ocr, camera: camera, footerButtons: footerButtons)
    ocrUseCase = W3WOcrUseCase(camera: camera, ocr: ocr, ocrOutput: ocrViewModel.output, ocrInput: ocrViewModel.input, pickerOutput: pickerViewModel.output, pickerInput: pickerViewModel.input)

    let ocrViewController = W3WOcrViewController(viewModel: ocrViewModel)
    super.init(rootViewController: ocrViewController)
    
    bind()
  }
  
  
  public override func start() {
    super.start()
  }

  
  // MARK: Bind the events

  
  func bind() {
    subscribe(to: ocrViewModel.output) { [weak self] event in
      self?.handle(ocrOutputEvent: event)
    }
  }
  

  // MARK: Event handlers

  
  func handle(ocrOutputEvent: W3WOcrOutputEvent) {
    
    if case .importImage = ocrOutputEvent {
      show(vc: makeImagePicker())
    }

    if case .footerButton(let factory, suggestions: let suggestions) = ocrOutputEvent {
      switch factory.action {
          
        case .viewControllerFactory(forSuggestions: let closure):
          show(vc: closure(suggestions))
          
        case .execute(forSuggestions: let closure):
          closure(suggestions)
      }
    }
  }
    
  
  // MARK: Make views

  
  func makeImagePicker() -> W3WImagePickerViewController {
    let picker = W3WImagePickerViewController()
    picker.set(viewModel: pickerViewModel)
    
    subscribe(to: pickerViewModel.output) { [weak self] event in
      if case .dismiss = event {
        picker.dismiss(animated: true)
      }
    }
    
    return picker
  }
  
}
