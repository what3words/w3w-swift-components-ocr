//
//  W3WOcrImagePickerUseCase.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 07/05/2025.
//

import CoreGraphics
import W3WSwiftCore


class W3WOcrPickerUseCase: W3WEventSubscriberProtocol {
  var subscriptions = W3WEventsSubscriptions()
  
  var pickerOutput: W3WEvent<W3WImagePickerOutputEvent>
  
  var pickerInput: W3WEvent<W3WImagePickerInputEvent>
  
  var ocr: W3WOcrProtocol?

  weak var ocrViewModel: (any W3WOcrViewModelProtocol)?
  
  init(pickerOutput: W3WEvent<W3WImagePickerOutputEvent>, pickerInput: W3WEvent<W3WImagePickerInputEvent>, ocr: W3WOcrProtocol?, ocrViewModel: any W3WOcrViewModelProtocol) {
    self.pickerOutput = pickerOutput
    self.pickerInput = pickerInput
    self.ocr = ocr
    self.ocrViewModel = ocrViewModel
    
    subscribe(to: pickerOutput) { [weak self] event in
      self?.handle(event: event)
    }
  }
  
  
  func handle(event: W3WImagePickerOutputEvent) {
    switch event {
        
      case .image(let image):
        handle(image: image)
      
      case .dismiss:
        print("dismiss goes here")
        
      case .error(let error):
        print(error)
    }
  }
  
  
  func handle(image: CGImage) {
    ocrViewModel?.set(image: image)
    
    ocr?.autosuggest(image: image, info: { _ in }) { [weak self] suggestions, error in
      self?.ocrViewModel?.ocrResults(suggestions: suggestions, error: error == nil ? nil : W3WError.other(error))
      ////guard let self else { return }
      //if self == nil {
      //  print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
      //
      //} else if let e = error {
      //  DispatchQueue.main.async {
      //    //self.handleOcrError(e)
      //    //self?.pickerOutput.send(.error(W3WError.message(e.description)))
      //    self?.ocrViewModel?.output.send(.error(W3WError.message(e.description)))
      //  }
      //} else {
      //  //DispatchQueue.main.async {
      //    self?.ocrViewModel?.handle(suggestions: suggestions)
      //  //}
      //}
    }
  }
  
}
