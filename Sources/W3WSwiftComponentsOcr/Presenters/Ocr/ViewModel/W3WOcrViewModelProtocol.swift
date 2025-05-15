//
//  W3WOcrViewModelProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes


public enum W3WOcrViewType {
  case video
  case still
  case uploaded
}



public protocol W3WOcrViewModelProtocol: ObservableObject {
  
  var input: W3WEvent<W3WOcrInputEvent> { get set }
  
  var output: W3WEvent<W3WOcrOutputEvent> { get set }
  
  var scheme: W3WScheme? { get set }

  var ocr: W3WOcrProtocol? { get set }
  
  var camera: W3WOcrCamera? { get set }
  
  var panelViewModel: W3WPanelViewModel { get set }

  var viewType: W3WOcrViewType { get set }

  var stillImage: CGImage? { get set }
  
  var spinner: Bool { get set }
  
  //var cameraMode: Bool { get set }
  
  // interation
  
  func importButtonPressed()
  
  func captureButtonPressed()
  
  func viewTypeSwitchEvent(on: Bool)
  
  func ocrResults(suggestions: [W3WSuggestion]?, error: W3WError?)
  
  func handle(suggestions: [W3WSuggestion]?)
  
  func set(image: CGImage)
}
