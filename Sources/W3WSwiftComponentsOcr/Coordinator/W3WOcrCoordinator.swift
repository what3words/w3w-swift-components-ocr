//
//  W3WOcrCoordinator.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 15/05/2025.
//

import UIKit
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftCoordinator
import W3WSwiftPresenters
import W3WSwiftAppEvents


open class W3WOcrCoordinator: W3WViewCoordinator, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  public let ocrViewModel: W3WOcrViewModel
  
  var ocrUseCase: W3WOcrUseCase?
  
  // preload this, it takes a long time to init when done on demand, make sure this isn't slowing the OCR startup
  let picker = UIImagePickerController()
  
  lazy var pickerViewModel = W3WImagePickerViewModel(picker: picker)

  var camera: W3WOcrCamera

  var appEvents = W3WEvent<W3WAppEvent>()
  
  var importLocked = W3WLive<Bool>(true)
  var liveScanLocked = W3WLive<Bool>(true)

  
  public init(ocr: W3WOcrProtocol, camera: W3WOcrCamera, footerButtons: [W3WSuggestionsViewControllerFactory], theme: W3WLive<W3WTheme?> = W3WLive<W3WTheme?>(.what3words), translations: W3WTranslationsProtocol) {
    self.camera = camera
    
    ocrViewModel = W3WOcrViewModel(ocr: ocr, camera: camera, footerButtons: footerButtons, translations: translations, theme: theme, importLocked: importLocked, liveScanLocked: liveScanLocked, events: appEvents)

    let ocrViewController = W3WOcrViewController(viewModel: ocrViewModel)
    super.init(rootViewController: ocrViewController)

    ocrUseCase = W3WOcrUseCase(camera: camera, ocr: ocr, ocrOutput: ocrViewModel.output, ocrInput: ocrViewModel.input, pickerOutput: pickerViewModel.output, pickerInput: pickerViewModel.input)

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

  
  open func handle(ocrOutputEvent: W3WOcrOutputEvent) {
    
    if case .importImage = ocrOutputEvent {
      show(vc: makeImagePicker())
    }

    if case .footerButton(let factory, suggestions: let suggestions) = ocrOutputEvent {
      factory.action(suggestions, rootViewController)
    }
  }
    
  
  // MARK: Make views

  
  public func makeImagePicker() -> UIImagePickerController {
    //let picker = W3WImagePickerViewController()
    //picker.set(viewModel: pickerViewModel)
    
    subscribe(to: pickerViewModel.output) { [weak self] event in
      if case .dismiss = event {
        self?.picker.dismiss(animated: true)
      }
    }
    
    return picker
  }
  
}
