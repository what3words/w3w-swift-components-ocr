//
//  File.swift
//  
//
//  Created by Dave Duprey on 13/01/2024.
//

import Foundation
import W3WSwiftThemes

public extension W3WTheme {
  
  /// function to make a theme suitable to use in the OCR Component
  /// - Parameters:
  ///   - text: colour for the text
  ///   - lightText: lighter colour for secondary text
  ///   - background: background colout
  ///   - lineDefault: viewfinder corner line colour
  ///   - lineSuccess: viewfinder corner line colour for when an address is found
  ///   - error:  viewfinder corner line colour for when there is an error
  static func forOcr(
    text:           W3WColor?  = .text,
    lightText:      W3WColor?  = .secondaryGray,
    background:     W3WColor?  = .background,
    lineDefault:    W3WColor?  = .white,
    lineSuccess:    W3WColor?  = .green,
    error:          W3WColor?  = .errorRed,
    lineThickness:  W3WLineThickness = .fourPoint,
    fonts:          W3WFonts   = W3WFonts(),
    padding:        W3WPadding = .none,
    rowHeight:      W3WRowHeight = .medium
    
  ) -> W3WTheme {

    let cornerRadius = W3WCornerRadius(value: lineThickness.value * 0.5)
    
    let ocrColours = W3WColors(foreground: text, background: background, success: W3WBasicColors(foreground: lineSuccess), error: W3WBasicColors(foreground: error), line: lineDefault)
    let ocrStyles  = W3WStyles(cornerRadius: cornerRadius, fonts: fonts, padding: padding, rowHeight: rowHeight, lineThickness: lineThickness)
    let ocrScheme  = W3WScheme(colors: ocrColours, styles: ocrStyles)
    
    return W3WTheme(base: .standard, cells: .standardCells, ocr: ocrScheme)
  }
  
}
