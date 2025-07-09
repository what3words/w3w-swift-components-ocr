//
//  W3WOcrScannerViewController.swift
//  TestOCR
//
//  Created by Dave Duprey on 04/06/2021.
//  Modified by Thy Nguyen 2024
//

import UIKit
import CoreLocation
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftDesign

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


/// the UIKit view controller holding the OCR view
@available(macCatalyst 14.0, *)
open class W3WOcrViewController<ViewModel: W3WOcrViewModelProtocol>: W3WHostingViewController<W3WOcrScreen<ViewModel>>, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  /// the UIKit OCR view
  var ocrView: W3WOcrView

  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  var customCrop: CGRect?

  /// keeps a reference to objects to keep them alive and release them on destruction
  public var keepAlive: [Any?]

  /// the view model for the OCR view
  var viewModel: ViewModel
  
  var buttonsHieght = CGFloat(180.0)

  /// view controller containing a Settings view
  /// - Parameters:
  ///     - viewModel: the viewmodel for the view
  ///     - theme: the theme stream
  public init(viewModel: ViewModel, keepAlive: [Any?] = []) {
    self.keepAlive = keepAlive
    self.viewModel = viewModel

    // make the UIKit OCR view
    ocrView = W3WOcrView(frame: .w3wWhatever)
    
    // attach the camera to the OCR view
    if let camera = viewModel.camera {
      ocrView.set(camera: camera)
    }
    
    // set the colours
    ocrView.set(lineColor: W3WCoreColor.white.uiColor, lineGap: 1.0)
    
    // make the SwitUI representable view for the UIKit view
    let ocrScreen = W3WOcrScreen(
      viewModel: viewModel,
      initialPanelHeight: 128.0,
      ocrView: ocrView
    )

    // start 'er up
    super.init(rootView: ocrScreen)
    
    // set colours and bind to themes
    view.backgroundColor = .clear
    ocrView.set(scheme: viewModel.theme.value?.ocrScheme(for: .idle))
    ocrView.set(lineColor: W3WCoreColor.white.uiColor, lineGap: 1.0)
    subscribe(to: viewModel.theme)  { [weak self] theme in
      W3WThread.queueOnMain {
        self?.ocrView.set(scheme: viewModel.theme.value?.ocrScheme(for: .idle))
      }
    }
    subscribe(to: viewModel.ocrCropRect)  { [weak self] rect in
      self?.customCrop = rect
      W3WThread.queueOnMain {
        self?.updateCrop()
      }
    }
  }

  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.input.send(.startScanning)
  }
  
  
  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.input.send(.pauseScanning)
  }
  
  
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  /// - Parameters:
  ///     - crop: camera crop to use specified in view coordinates
  public func set(crop: CGRect?) {
    self.customCrop = crop
  }

  
  /// set the OCR crop to a value that makes sense for the current view
  func updateCrop() {
    if let customCrop = customCrop {
      ocrView.set(crop: customCrop)
    } else {
      ocrView.set(crop: defaultCrop())
    }
  }

  
  /// calculate a good crop for the OCR viewfinder
  func defaultCrop() -> CGRect {
    let inset = W3WSettings.ocrCropInset
    let width: CGFloat
    let height: CGFloat
    
    // iPad width and height
    if UIDevice.current.userInterfaceIdiom == .pad {
      width = ocrView.bounds.width - inset * 2.0
      height = width * 0.75
      
    // potrait width and height
    } else  if ocrView.bounds.width < ocrView.bounds.height {
      width = ocrView.bounds.width - inset * 2.0
      height = width
      
    // landscape width and height
    } else {
      width = ocrView.bounds.width * 0.8 - inset * 2.0
      height = width * W3WSettings.ocrViewfinderRatioLandscape
    }
    
    // the crop
    let crop = CGRect(
      origin: CGPoint(
        x: (ocrView.bounds.width - width) / 2,
        y: W3WSettings.ocrCropInset * 2.0 + view.safeAreaInsets.top),
      size: CGSize(
        width: width,
        height: height
      )
    )
    
    return crop
  }

  
  /// when the window dimensions change, update the OCR viewfinder crop
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateCrop()
  }
  
  
}

