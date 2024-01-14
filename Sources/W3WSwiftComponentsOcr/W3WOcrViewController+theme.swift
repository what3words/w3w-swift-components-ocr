//
//  W3WOcrViewController+theme.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 19/12/2023.
//

import UIKit
import W3WSwiftCore
import W3WSwiftThemes

extension W3WOcrViewController {
  public func setupOcrScheme() {
    if theme == nil {
      theme = .standard
    }
    for state in W3WOcrState.allCases {
      guard theme?.getOcrScheme(state: state) == nil else {
        continue
      }
      let scheme: W3WScheme
      switch state {
      
      case .idle:
        scheme = W3WScheme(
        
          colors: W3WColors(
            foreground: theme?[.ocr]?.colors?.foreground,
            background: theme?[.ocr]?.colors?.background,
            line:       theme?[.ocr]?.colors?.line
          ),
         
          styles: W3WStyles(
            cornerRadius: theme?[.ocr]?.styles?.cornerRadius,
            fonts: theme?[.ocr]?.styles?.fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: theme?[.ocr]?.styles?.padding,
            rowHeight: W3WRowHeight(floatLiteral: Float((theme?[.ocr]?.styles?.rowHeight?.value ?? 0.0) / 2.0)),
            lineThickness: theme?[.ocr]?.styles?.lineThickness
          )
        )
        
      case .detecting:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: theme?[.ocr]?.colors?.foreground,
            background: theme?[.ocr]?.colors?.background,
            line:       theme?[.ocr]?.colors?.line
          ),
          
          styles: W3WStyles(
            cornerRadius: W3WCornerRadius(value: (theme?[.ocr]?.styles?.cornerRadius?.value ?? 0.0) * 2.0),
            fonts: theme?[.ocr]?.styles?.fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: theme?[.ocr]?.styles?.padding,
            rowHeight: theme?[.ocr]?.styles?.rowHeight,
            lineThickness: W3WLineThickness(value: (theme?[.ocr]?.styles?.lineThickness?.value ?? 0.0) * 2.0)
          )
        )
        
      case .scanning:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: theme?[.ocr]?.colors?.foreground,
            background: theme?[.ocr]?.colors?.background,
            line:       theme?[.ocr]?.colors?.success?.foreground
          ),
          
          styles: W3WStyles(
            cornerRadius: W3WCornerRadius(value: (theme?[.ocr]?.styles?.cornerRadius?.value ?? 0.0) * 2.0),
            fonts: theme?[.ocr]?.styles?.fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: theme?[.ocr]?.styles?.padding,
            rowHeight: theme?[.ocr]?.styles?.rowHeight,
            lineThickness: W3WLineThickness(value: (theme?[.ocr]?.styles?.lineThickness?.value ?? 0.0) * 2.0)
          )
        )
        
      case .scanned:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: theme?[.ocr]?.colors?.secondary,
            background: theme?[.ocr]?.colors?.background,
            line:       theme?[.ocr]?.colors?.line
          ),
          
          styles: W3WStyles(
            cornerRadius: theme?[.ocr]?.styles?.cornerRadius,
            fonts: theme?[.ocr]?.styles?.fonts,
            textAlignment: W3WTextAlignment(value: .left),
            padding: theme?[.ocr]?.styles?.padding,
            rowHeight: W3WRowHeight(floatLiteral: Float((theme?[.ocr]?.styles?.rowHeight?.value ?? 0.0) / 2.0)),
            lineThickness: theme?[.ocr]?.styles?.lineThickness
          )
        )
        
      case .error:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: theme?[.ocr]?.colors?.foreground,
            background: theme?[.ocr]?.colors?.background,
            line:       theme?[.ocr]?.colors?.error?.foreground
          ),
          
          styles: W3WStyles(
            cornerRadius: W3WCornerRadius(value: (theme?[.ocr]?.styles?.cornerRadius?.value ?? 0.0) * 2.0),
            fonts: theme?[.ocr]?.styles?.fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: W3WPadding(insets: .zero),
            rowHeight: theme?[.ocr]?.styles?.rowHeight,
            lineThickness: W3WLineThickness(value: (theme?[.ocr]?.styles?.lineThickness?.value ?? 0.0) * 2.0)
          )
        )
      }
      
      theme?[state.setType] = scheme
    }
  }
}

extension W3WTheme {
  func getOcrScheme(state: W3WOcrState) -> W3WScheme? {
    return self[state.setType]
  }
}

extension W3WSetTypes {
  public static let ocrIdle: W3WSetTypes = "ocr.idle"
  public static let ocrDetecting: W3WSetTypes = "ocr.detecting"
  public static let ocrScanning: W3WSetTypes = "ocr.scanning"
  public static let ocrScanned: W3WSetTypes = "ocr.scanned"
  public static let ocrError: W3WSetTypes = "ocr.error"
}

extension W3WOcrState {
  public var setType: W3WSetTypes {
    switch self {
    case .idle:
      return .ocrIdle
    case .detecting:
      return .ocrDetecting
    case .scanning:
      return .ocrScanning
    case .scanned:
      return .ocrScanned
    case .error:
      return .ocrError
    }
  }
}
