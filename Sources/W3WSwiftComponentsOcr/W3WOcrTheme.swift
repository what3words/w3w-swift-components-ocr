//
//  W3WOcrTheme.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 15/12/2023.
//

import UIKit
import W3WSwiftThemes

extension W3WColors {
  
  public static let ocrBaseColors = W3WColors.standard
    .with(foreground: .text)
    .with(background: .background)
  
//  W3WColors(
//    foreground: .text,
//    background: .background,
//    tint: W3WColor? = nil,
//    secondary: W3WColor? = nil,
//    brand: W3WColor? = nil,
//    highlight: W3WBasicColors? = nil,
//    border: W3WColor? = nil,
//    separator: W3WColor? = nil,
//    shadow: W3WColor? = nil,
//    placeholder: W3WColor? = nil,
//    success: W3WBasicColors? = nil,
//    error: W3WBasicColors? = nil,
//    header: W3WBasicColors? = nil,
//    line: W3WColor? = nil
//  )
  
  public static let ocrCellsColors = W3WColors.standard
}

extension W3WStyles {
  public static let ocrBaseStyles = W3WStyles.standard
  public static let ocrCellsStyles = W3WStyles.standard
}

extension W3WScheme {
  public static let ocrBase  = W3WScheme(colors: W3WColors.ocrBaseColors, styles: W3WStyles.ocrBaseStyles)
  public static let ocrCells = W3WScheme(colors: W3WColors.ocrCellsColors, styles: W3WStyles.ocrCellsStyles)
}

extension W3WTheme {
  public static let ocrBase = W3WTheme(
    base: W3WScheme.ocrBase,
    cells: W3WScheme.ocrCells
  )
  
  static public func ocrTheme(textColor: W3WColor, outlineColor: W3WColor, outlineThickness: CGFloat) -> W3WTheme {
    return W3WTheme(base: .standard)
  }

}





//func configure() {
//  
//  let theme = W3WTheme(base: W3WScheme.ocrBase, cells: W3WScheme.ocrCells)
//  theme.add("ocrDetecting", W3WScheme())
//  
//}


//public struct W3WOcrTheme {
//  public var idleStyle: W3WOcrStyle = .defaultIdleStyle
//  public var detectingStyle: W3WOcrStyle = .defaultDetectingStyle
//  public var scanningStyle: W3WOcrStyle = .defaultScanningStyle
//  public var errorStyle: W3WOcrStyle = .defaultErrorStyle
//}
//
//extension W3WOcrTheme{
//  static var defaultTheme: W3WOcrTheme {
//    return W3WOcrTheme()
//  }
//}
