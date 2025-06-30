//
//  W3WOcrStillViewController.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 28/06/2025.
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
open class W3WOcrStillViewController<ViewModel: W3WOcrStillViewModelProtocol>: W3WHostingViewController<W3WOcrStillScreen<ViewModel>>, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()
  
  /// keeps a reference to objects to keep them alive and release them on destruction
  public var keepAlive: [Any?]
  
  /// the view model
  var viewModel: ViewModel
  
  /// detents for the bottom sheet to snap to
  var detents = W3WDetents(detent: 0.0)

  // magic numbers (😬) for the initial values - move these elsewhere...
  var bottomDetent = CGFloat(90.0)
  var buttonsHieght = CGFloat(180.0)
  
  
  /// the UIKit view controller holding the OCR view
  /// - Parameters:
  ///     - viewModel: the viewmodel for the view
  ///     - theme: the theme stream
  public init(viewModel: ViewModel, keepAlive: [Any?] = []) {
    self.keepAlive = keepAlive
    self.viewModel = viewModel

    // the ocr screen for still image
    let ocrScreen = W3WOcrStillScreen(viewModel: viewModel, initialPanelHeight: buttonsHieght, detents: detents)

    // initialise the swiftui vie using the uikit view
    super.init(rootView: ocrScreen)
    
    // initialise the detents
    resetDetents()
  }

  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// set the detents to places that make sense
  func resetDetents(middle: CGFloat? = nil) {
    detents.add(detent: bottomDetent)
    
    if let m = middle {
      detents.add(detent: m)
    }
    
    detents.add(detent: view.frame.maxY - W3WPadding.heavy.value - buttonsHieght)
  }
  
}

