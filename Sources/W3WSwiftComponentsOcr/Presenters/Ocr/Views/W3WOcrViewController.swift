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
open class W3WOcrViewController<ViewModel: W3WOcrViewModelProtocol>: W3WHostingViewController<W3WOcrScreen<ViewModel>> {

  /// keeps a reference to objects to keep them alive and release them on destruction
  public var keepAlive: [Any?]

  /// the view model for the OCR view
  private let viewModel: ViewModel
  

  /// view controller containing a Settings view
  /// - Parameters:
  ///     - viewModel: the viewmodel for the view
  ///     - theme: the theme stream
  public init(viewModel: ViewModel, keepAlive: [Any?] = []) {
    self.keepAlive = keepAlive
    self.viewModel = viewModel
    
    // make the SwitUI representable view for the UIKit view
    let ocrScreen = W3WOcrScreen(viewModel: viewModel)

    // start 'er up
    super.init(rootView: ocrScreen)
  }

  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.input.send(.startScanning)
  }
}

