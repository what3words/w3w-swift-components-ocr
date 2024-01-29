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
  ///   - lightText: lighter colour for secondary text
  ///   - background: background colout
  ///   - lineDefault: viewfinder corner line colour
  ///   - lineSuccess: viewfinder corner line colour for when an address is found
  ///   - padding: padding between viewfinder and camera view
  ///   - rowHeight: viewfinder line length
  ///   - error:  viewfinder corner line colour for when there is an error
  static func forOcr(
    text:           W3WColor?  = .bottomSheetBodyText,
    footnoteText:   W3WColor?  = .bottomSheetFootnoteText,
    background:     W3WColor?  = .background,
    lineDefault:    W3WColor?  = .white,
    lineSuccess:    W3WColor?  = .green,
    error:          W3WColor?  = .errorRed,
    lineThickness:  W3WLineThickness = .fourPoint,
    fonts:          W3WFonts   = W3WFonts(body: .systemFont(ofSize: 17.0, weight: .semibold),
                                          headline: .systemFont(ofSize: 17.0, weight: .bold),
                                          footnote: .systemFont(ofSize: 13.0, weight: .bold),
                                          caption1: .systemFont(ofSize: 13.0)),
    padding:        W3WPadding = .none,
    rowHeight:      W3WRowHeight = .medium,
    bottomSheet:    W3WColor?  = .bottomSheetBackground
    
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
