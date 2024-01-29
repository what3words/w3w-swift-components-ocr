//
//  File.swift
//  
//
//  Created by Dave Duprey on 13/01/2024.
//

import UIKit
import Foundation
import W3WSwiftThemes

public extension W3WTheme {
  
  /// function to make a theme suitable to use in the OCR Component
  /// - Parameters:
  ///   - text: colour for the text
  ///   - footnoteText: colour for footnote text
  ///   - errorText: colour for error text
  ///   - error: viewfinder corner line colour for when there is an error
  ///   - bottomSheet: background colour for bottomsheet
  ///   - background: screen background colour
  ///   - lineDefault: viewfinder corner line colour
  ///   - lineSuccess: viewfinder corner line colour for when an address is found
  ///   - lineThickness: viewfinder line width
  ///   - rowHeight: viewfinder line length
  ///   - padding: padding between viewfinder and camera view
  ///   - fonts: fonts of all needed styles for text
  
  static func forOcr(
    text:           W3WColor?  = .bottomSheetBodyText,
    footnoteText:   W3WColor?  = .bottomSheetFootnoteText,
    errorText:      W3WColor?  = .labelError,
    error:          W3WColor?  = .errorRed,
    bottomSheet:    W3WColor?  = .bottomSheetBackground,
    background:     W3WColor?  = .background,
    lineDefault:    W3WColor?  = .white,
    lineSuccess:    W3WColor?  = .green,
    lineThickness:  W3WLineThickness = .fourPoint,
    rowHeight:      W3WRowHeight = .medium,
    padding:        W3WPadding = .none,
    fonts:          W3WFonts   = W3WFonts(body: .systemFont(ofSize: 17.0, weight: .semibold),
                                          headline: .systemFont(ofSize: 17.0, weight: .bold),
                                          footnote: .systemFont(ofSize: 13.0, weight: .bold),
                                          caption1: .systemFont(ofSize: 13.0))
  ) -> W3WTheme {

    let baseColours: W3WColors = .standard
      .with(background: .darkBlue)
      .with(foreground: text)
      .with(secondary: footnoteText)
      .with(line: lineDefault)
    let baseStyles: W3WStyles = .standard
      .with(fonts: fonts)
      .with(textAlignment: W3WTextAlignment(value: .center))
      .with(lineThickness: .fourPoint)
      .with(rowHeight: W3WRowHeight(value: rowHeight.value * 0.5))
      .with(cornerRadius: W3WCornerRadius(value: lineThickness.value * 0.5))
    let standardScheme: W3WScheme = .init(colors: baseColours, styles: baseStyles)
    
    let ocrColours = W3WColors(foreground: text,
                               background: bottomSheet,
                               secondary: errorText,
                               success: W3WBasicColors(foreground: lineSuccess),
                               error: W3WBasicColors(foreground: error),
                               line: lineSuccess)
    let ocrStyles  = W3WStyles(cornerRadius: W3WCornerRadius(value: lineThickness.value * 1.5),
                               fonts: fonts,
                               textAlignment: W3WTextAlignment(value: .left),
                               padding: padding,
                               rowHeight: rowHeight,
                               lineThickness: W3WLineThickness(value: lineThickness.value * 3))
    let ocrScheme  = W3WScheme(colors: ocrColours, styles: ocrStyles)
    
    return W3WTheme(base: standardScheme, cells: .standardCells, ocr: ocrScheme)
  }
  
}
