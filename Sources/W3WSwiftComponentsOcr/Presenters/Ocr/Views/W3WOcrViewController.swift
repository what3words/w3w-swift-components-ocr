//
//  W3WOcrScannerViewController.swift
//  TestOCR
//
//  Created by Dave Duprey on 04/06/2021.
//  Modified by Thy Nguyen 2024
//

import UIKit
import W3WSwiftCore
import W3WSwiftDesign
import CoreLocation

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


@available(macCatalyst 14.0, *)
open class W3WOcrViewController<ViewModel: W3WOcrViewModelProtocol>: W3WHostingViewController<W3WOcrScreen<ViewModel>>, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  var ocrView: W3WOcrView

  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  var customCrop: CGRect?

  /// keeps a reference to objects to keep them alive and release them on destruction
  public var keepAlive: [Any?]
  
  // maybe we prelaod this for efficiancy?  sometimes it takes a couple seconds to come up
  //var picker: W3WImagePickerViewController?

  var detents = W3WDetents(detent: 0.0)
  
  //var picker: W3WImagePickerViewController?
  
  var viewModel: ViewModel
  
  //var pickerUseCase: W3WOcrImagePickerUseCase?
  
  var bottomDetent = CGFloat(90.0)
  
  var buttonsHieght = CGFloat(180.0)
  
  
  /// view controller containing a Settings view
  /// - Parameters:
  ///     - viewModel: the viewmodel for the view
  ///     - theme: the theme stream
  public init(viewModel: ViewModel, keepAlive: [Any?] = []) {
    self.keepAlive = keepAlive
    self.viewModel = viewModel

    //let ocrMainViewController = W3WOcrBaseViewController(ocr: viewModel.ocr)
    //self.keepAlive.append(ocrMainViewController)
    
    ocrView = W3WOcrView(frame: .w3wWhatever)

    if let camera = viewModel.camera {
      ocrView.set(camera: camera)
    }
        
    let ocrScreen = W3WOcrScreen(viewModel: viewModel, initialPanelHeight: 128.0, ocrView: ocrView, detents: detents)

    super.init(rootView: ocrScreen)
    
    //detents = W3WDetents(detents: [bottomDetent])
    resetDetents()
    
    view.backgroundColor = .clear
    
    ocrView.set(scheme: viewModel.theme.value?.ocrScheme(for: .idle))
    ocrView.set(lineColor: W3WCoreColor.white.uiColor, lineGap: 1.0)
    subscribe(to: viewModel.theme)  { [weak self] theme in
      W3WThread.queueOnMain {
        self?.ocrView.set(scheme: viewModel.theme.value?.ocrScheme(for: .idle))
      }
    }

  }

  
  
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  /// - Parameters:
  ///     - crop: camera crop to use specified in view coordinates
  public func set(crop: CGRect?) {
    self.customCrop = crop
  }

  
  func updateCrop() {
    if let customCrop = customCrop {
      ocrView.set(crop: customCrop)
    } else {
      ocrView.set(crop: defaultCrop())
    }
    
    resetDetents(middle: ocrView.crop.maxY - W3WPadding.heavy.value - buttonsHieght)
  }
  
  
  func resetDetents(middle: CGFloat? = nil) {
    detents.add(detent: bottomDetent)
    
    if let m = middle {
      detents.add(detent: m)
    }
    
    detents.add(detent: view.frame.maxY - W3WPadding.heavy.value - buttonsHieght)
  }
  
  
  func defaultCrop() -> CGRect {
    let inset = W3WSettings.ocrCropInset
    let width: CGFloat
    let height: CGFloat
    if UIDevice.current.userInterfaceIdiom == .pad {
      width = ocrView.bounds.width - inset * 2.0
      height = width * 0.75
    } else  if ocrView.bounds.width < ocrView.bounds.height {
      // potrait
      width = ocrView.bounds.width - inset * 2.0
      height = width
    } else {
      // landscape
      width = ocrView.bounds.width * 0.8 - inset * 2.0
      height = width * W3WSettings.ocrViewfinderRatioLandscape
    }
    let crop = CGRect(
      origin: CGPoint(
        x: (ocrView.bounds.width - width) / 2,
        y: W3WRowHeight.extraLarge.value), //W3WSettings.ocrCropInset * 2.0),
        //y: W3WSettings.ocrTopPadding),
      size: CGSize(
        width: width,
        height: height
      )
    )
    
    return crop
  }

  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateCrop()
  }
  
  
}

