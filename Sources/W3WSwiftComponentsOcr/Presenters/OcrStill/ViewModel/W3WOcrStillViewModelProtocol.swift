//
//  W3WOcrStillViewModelProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 28/06/2025.
//

import Combine
import CoreGraphics
import W3WSwiftThemes
import W3WSwiftPresenters


/// a protocol for view model for still image ocr
public protocol W3WOcrStillViewModelProtocol: ObservableObject {
  
  /// input events for still imagfe ocr
  var input: W3WEvent<W3WOcrStillInputEvent> { get set }
  
  /// output events for still imagfe ocr
  var output: W3WEvent<W3WOcrStillOutputEvent> { get set }
  
  /// indicates that if the ocr did collects any suggestions
  var hasSuggestions: Bool { get }
  
  /// the scheme to use
  var scheme: W3WScheme? { get set }

  /// the translations
  var translations: W3WTranslationsProtocol { get }
  
  /// the image to scan
  var image: CGImage? { get set }
  
  /// progress indicator
  var isLoading: Bool { get set }
  
  /// the view model for the bottom sheet panel
  var panelViewModel: W3WPanelViewModel { get set }
  
  /// called by UI when the dismiss button is pressed
  func dismissButtonPressed()
}
