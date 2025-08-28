//
//  W3WOcrViewModelProtocol.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftPresenters


/// protocol for view model for the ocr view
public protocol W3WOcrViewModelProtocol: ObservableObject {
  
  /// ocr inout events
  var input: W3WEvent<W3WOcrInputEvent> { get set }
  
  /// ocr output events
  var output: W3WEvent<W3WOcrOutputEvent> { get set }
  
  @available(*, deprecated, message: "replaced with theme")
  var scheme: W3WScheme? { get set }

  /// theme for the view
  var theme: W3WLive<W3WTheme?> { get set }

  /// scheme for the bottom sheet
  var bottomSheetScheme: W3WScheme? { get set }

  /// the ocr service
  var ocr: W3WOcrProtocol? { get set }
  
  /// the camera
  var camera: W3WOcrCamera? { get }
  
  /// the ocr service crop rect
  var ocrCropRect: W3WEvent<CGRect> { get }
  
  /// view model for the panel in the bottom sheet
  var panelViewModel: W3WPanelViewModel { get set }
  
  /// indicates if there is a photo being processed
  var isTakingPhoto: Bool { get }
  
  /// the view mode - for still / live - perhaps depricated?
  var viewType: W3WOcrViewType { get set }

  /// translations for text
  var translations: W3WTranslationsProtocol { get set }
  
  /// the binding to the lock on the import button
  var lockOnImportButton: Bool { get set }

  /// the binding to the lock on the live/still switch
  var lockOnLiveSwitch: Bool { get set }
}
