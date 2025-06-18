//
//  W3WOcrStillViewModelProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 17/06/2025.
//


import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters



public protocol W3WOcrStillViewModelProtocol: ObservableObject {
  
  var input: W3WEvent<W3WOcrStillInputEvent> { get set }
  
  var output: W3WEvent<W3WOcrStillOutputEvent> { get set }
  
  var theme: W3WLive<W3WTheme?> { get set }

  var bottomSheetScheme: W3WScheme? { get set }
  
  var ocr: W3WOcrProtocol? { get set }
  
  var camera: W3WOcrCamera? { get set }
  
  var panelViewModel: W3WPanelViewModel { get set }

  //var viewType: W3WOcrViewType { get set }

  var stillImage: CGImage? { get set }
  
  var translations: W3WTranslationsProtocol { get set }
  
  //var spinner: Bool { get set }
  
  //var cameraMode: Bool { get set }
  
  // interation
  
  func importButtonPressed()
  
  func captureButtonPressed()
  
  func viewTypeSwitchEvent(on: Bool)
  
  func closeButtonPressed()
  
  //func ocrResults(suggestions: [W3WSuggestion]?, error: W3WError?)
  
  func handle(suggestions: [W3WSuggestion]?)
  
  //func set(image: CGImage)
}
