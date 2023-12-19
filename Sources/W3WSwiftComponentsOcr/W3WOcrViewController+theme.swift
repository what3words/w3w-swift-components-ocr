//
//  W3WOcrViewController+theme.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 19/12/2023.
//

import UIKit
import W3WSwiftCore
import W3WSwiftThemes

extension W3WScheme {
  static var standardOcrScheme: W3WScheme {
    let idleColors = W3WColors(foreground: W3WColor(uiColor: .black), line: W3WColor(uiColor: .white))
    let detectingColors = W3WColors(foreground: W3WColor(uiColor: .black), line: W3WColor(uiColor: .white))
    let scanningColors = W3WColors(foreground: W3WColor(uiColor: .black), line: W3WColor(uiColor: W3WSettings.ocrTargetSuccess))
    let scannedColors = W3WColors(foreground: W3WColor(uiColor: .gray), line: W3WColor(uiColor: .white))
    let errorColors = W3WColors(foreground: W3WColor(uiColor: .black), line: W3WColor(uiColor: W3WSettings.ocrTargetFailed))
    
    let padding = W3WPadding(insets: .zero)
    let shortLineLength = W3WRowHeight(floatLiteral: 48.0)
    let longLineLength = W3WRowHeight(floatLiteral: 48.0)
    
    let idleStyles = W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 3.0),
                               fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                               padding: padding,
                               rowHeight: shortLineLength,
                               lineThickness: W3WLineThickness(floatLiteral: 6.0)
    )
    let detectingStyles = W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                    fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                    padding: padding,
                                    rowHeight: longLineLength,
                                    lineThickness: W3WLineThickness(floatLiteral: 12.0)
    )
    let scanningStyles = W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                   fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                   padding: padding,
                                   rowHeight: longLineLength,
                                   lineThickness: W3WLineThickness(floatLiteral: 12.0)
    )
    let scannedStyles = W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 3.0),
                                  fonts: W3WFonts(font: .systemFont(ofSize: 14.0, weight: .regular)),
                                  padding: padding,
                                  rowHeight: shortLineLength,
                                  lineThickness: W3WLineThickness(floatLiteral: 6.0)
    )
    let errorStyles = W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                padding: padding,
                                rowHeight: longLineLength,
                                lineThickness: W3WLineThickness(floatLiteral: 12.0)
    )
    
    let idleScheme = W3WScheme(colors: idleColors, styles: idleStyles)
    let detectingScheme = W3WScheme(colors: detectingColors, styles: detectingStyles)
    let scanningScheme = W3WScheme(colors: scanningColors, styles: scanningStyles)
    let scannedScheme = W3WScheme(colors: scannedColors, styles: scannedStyles)
    let errorScheme = W3WScheme(colors: errorColors, styles: errorStyles)
    
    let ocrScheme = W3WScheme(subschemes: [
      W3WOcrState.idle.rawValue: idleScheme,
      W3WOcrState.detecting.rawValue: detectingScheme,
      W3WOcrState.scanning.rawValue: scanningScheme,
      W3WOcrState.scanned.rawValue: scannedScheme,
      W3WOcrState.error.rawValue: errorScheme,
    ])
    return ocrScheme
  }
}

extension W3WOcrViewController {
  public func setupOcrScheme() {
    if theme == nil {
      theme = W3WTheme()
    }
    if theme?[.ocr] == nil {
      theme?[.ocr] = .standardOcrScheme
    }
  }
}
