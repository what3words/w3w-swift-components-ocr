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
  
  func basicScheme() -> W3WScheme {
    return W3WScheme(
      colors: W3WColors(
        foreground: labelsPrimary,
        background: fillsPrimary,
        tint: brandBase,
        secondary: labelsQuaternary,
        secondaryBackground: fillsQuaternary,
        brand: brandBase,
        highlight: W3WBasicColors(foreground: labelsTertiary, background: fillsTertiary),
        border: separatorNonOpaque,
        separator: separatorNonOpaque,
        shadow: separatorNonOpaque,
        placeholder: separatorNonOpaque,
        success: W3WBasicColors(foreground: successLabel, background: successBase),
        warning: W3WBasicColors(foreground: warningLabel, background: warningBase),
        error: W3WBasicColors(foreground: errorLabel, background: errorBase),
        header: W3WBasicColors(foreground: labelsQuaternary, background: fillsQuaternary),
        line: separatorNonOpaque),
      styles: nil
    )
  }
  
  
  /// user defined theme for ocr component
  /// if a parameter is not specified, corresponding value from standard theme will be applied
  /// - Parameters:
  ///   - backgroundColor: screen background colour
  ///   - bottomSheetBackgroundColor: background colour for bottomsheet
  ///   - headerTextColor: colour for the header
  ///   - brandColor: colour for the brand
  ///   - addressTextColor: colour for the address text
  ///   - footnoteTextColor: colour for the footnote texts
  ///   - errorTextColor:  colour for the error text
  ///   - fonts: fonts of all needed styles for text
  ///   - defaultLineColor: viewfinder corner line colour
  ///   - successLineColor: viewfinder corner line colour for when an address is found
  ///   - errorLineColor: viewfinder corner line colour for when there is an error
  ///   - defaultLineThickness: viewfinder line width
  ///   - boldLineThickness: viewfinder line width in bold style
  ///   - defaultLineLength: viewfinder line length
  ///   - boldLineLength: viewfinder line length in bold style
  ///   - withCornerRadius: viewfinder corncer line has corner radius or not
  ///   - padding: padding between viewfinder and camera view
  static func forOcr(
    backgroundColor: W3WColor? = nil,
    bottomSheetBackgroundColor: W3WColor? = nil,
    cameraBackgroundColor: W3WColor? = nil,
    headerTextColor: W3WColor? = nil,
    brandColor: W3WColor? = nil,
    addressTextColor: W3WColor? = nil,
    footnoteTextColor: W3WColor? = nil,
    errorTextColor: W3WColor? = nil,
    fonts: W3WFonts? = nil,
    defaultLineColor: W3WColor? = nil,
    successLineColor: W3WColor? = nil,
    errorLineColor: W3WColor? = nil,
    defaultLineThickness: W3WLineThickness? = nil,
    boldLineThickness: W3WLineThickness? = nil,
    defaultLineLength: W3WRowHeight? = nil,
    boldLineLength: W3WRowHeight? = nil,
    withCornerRadius: Bool = false,
    padding: W3WPadding? = nil
  ) -> W3WTheme {
    return .standard.withOcrStateSchemes(backgroundColor: backgroundColor,
                                         bottomSheetBackgroundColor: bottomSheetBackgroundColor,
                                         cameraBackgroundColor: cameraBackgroundColor,
                                         headerTextColor: headerTextColor,
                                         brandColor: brandColor,
                                         addressTextColor: addressTextColor,
                                         footnoteTextColor: footnoteTextColor,
                                         errorTextColor: errorTextColor,
                                         fonts: fonts,
                                         defaultLineColor: defaultLineColor,
                                         successLineColor: successLineColor,
                                         errorLineColor: errorLineColor,
                                         defaultLineThickness: defaultLineThickness,
                                         boldLineThickness: boldLineThickness,
                                         defaultLineLength: defaultLineLength,
                                         boldLineLength: boldLineLength,
                                         withCornerRadius: withCornerRadius,
                                         padding: padding)
  }
  
  /// transform current theme to an ocr component applicable theme with schemes for multiple ocr states
  /// if a parameter is not specified, corresponding value from current theme will be applied
  /// - Parameters:
  ///   - backgroundColor: screen background colour
  ///   - bottomSheetBackgroundColor: background colour for bottomsheet
  ///   - headerTextColor: colour for the header
  ///   - brandColor: colour for the brand
  ///   - addressTextColor: colour for the address text
  ///   - footnoteTextColor: colour for the footnote texts
  ///   - errorTextColor:  colour for the error text
  ///   - fonts: fonts of all needed styles for text
  ///   - defaultLineColor: viewfinder corner line colour
  ///   - successLineColor: viewfinder corner line colour for when an address is found
  ///   - errorLineColor: viewfinder corner line colour for when there is an error
  ///   - defaultLineThickness: viewfinder line width
  ///   - boldLineThickness: viewfinder line width in bold style
  ///   - defaultLineLength: viewfinder line length
  ///   - boldLineLength: viewfinder line length in bold style
  ///   - withCornerRadius: viewfinder corncer line has corner radius or not
  ///   - padding: padding between viewfinder and camera view
  func withOcrStateSchemes(
    backgroundColor: W3WColor? = nil,
    bottomSheetBackgroundColor: W3WColor? = nil,
    cameraBackgroundColor: W3WColor? = nil,
    headerTextColor: W3WColor? = nil,
    brandColor: W3WColor? = nil,
    addressTextColor: W3WColor? = nil,
    footnoteTextColor: W3WColor? = nil,
    errorTextColor: W3WColor? = nil,
    fonts: W3WFonts? = nil,
    defaultLineColor: W3WColor? = nil,
    successLineColor: W3WColor? = nil,
    errorLineColor: W3WColor? = nil,
    defaultLineThickness: W3WLineThickness? = nil,
    boldLineThickness: W3WLineThickness? = nil,
    defaultLineLength: W3WRowHeight? = nil,
    boldLineLength: W3WRowHeight? = nil,
    withCornerRadius: Bool = false,
    padding: W3WPadding? = nil
  ) -> W3WTheme {
    // Background color
    let backgroundColor: W3WColor? = backgroundColor ?? self[.ocr]?.colors?.background
    let bottomSheetBackgroundColor: W3WColor? = bottomSheetBackgroundColor ?? self[.ocr]?.colors?.secondaryBackground
    
    /// Text color
    let headerTextColor: W3WColor? = headerTextColor ?? self[.ocr]?.colors?.foreground
    let brandColor: W3WColor? = brandColor ?? self[.ocr]?.colors?.brand
    let addressTextColor: W3WColor? = addressTextColor ?? self[.ocr]?.colors?.foreground
    let footnoteTextColor: W3WColor? = footnoteTextColor ?? self[.ocr]?.colors?.secondary
    let errorTextColor: W3WColor? = errorTextColor ?? self[.ocr]?.colors?.error?.foreground
    
    // Fonts
    let fonts = fonts ?? self[.ocr]?.styles?.fonts
    
    // View finder
    /// Line color
    let defaultLineColor: W3WColor? = defaultLineColor ?? self[.ocr]?.colors?.line
    let successLineColor: W3WColor? = successLineColor ?? self[.ocr]?.colors?.success?.background
    let errorLineColor: W3WColor? = errorLineColor ?? self[.ocr]?.colors?.error?.background
    /// Line thickness
    let defaultLineThickness: W3WLineThickness = defaultLineThickness ?? 4.0
    let boldLineThickness: W3WLineThickness = boldLineThickness ?? 8.0
    /// Line length
    let defaultLineLength: W3WRowHeight = defaultLineLength ?? 24.0
    let boldLineLength: W3WRowHeight = boldLineLength ?? 48.0
    
    var resultTheme = self
    let ocrBaseColors: W3WColors? = self[.ocr]?.colors?
      .with(background: backgroundColor)
      .with(secondaryBackground: bottomSheetBackgroundColor)
      .with(foreground: addressTextColor)
      .with(secondary: footnoteTextColor)
      .with(brand: brandColor)
    let ocrBaseStyles: W3WStyles? = self[.ocr]?.styles?
      .with(fonts: fonts)
    resultTheme[.ocr] = self[.ocr]?.with(colors: ocrBaseColors).with(styles: ocrBaseStyles)
    
    for state in W3WOcrState.allCases {
      guard getOcrScheme(state: state) == nil else {
        continue
      }
      let scheme: W3WScheme
      switch state {
      case .idle:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: headerTextColor,
            background: cameraBackgroundColor ?? W3WColor.darkBlueAlpha60,
            line: defaultLineColor
          ),
          styles: W3WStyles(
            cornerRadius: withCornerRadius ? W3WCornerRadius(value: defaultLineThickness.value / 2.0) : 0.0,
            fonts: fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: padding ?? W3WPadding(value: -defaultLineThickness.value / 2.0),
            rowHeight: defaultLineLength,
            lineThickness: defaultLineThickness
          )
        )
        
      case .detecting:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: headerTextColor,
            background: cameraBackgroundColor ?? W3WColor.darkBlueAlpha60,
            line: defaultLineColor
          ),
          styles: W3WStyles(
            cornerRadius: withCornerRadius ? W3WCornerRadius(value: boldLineThickness.value / 2.0) : 0.0,
            fonts: fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: padding ?? W3WPadding(value: -boldLineThickness.value / 2.0),
            rowHeight: boldLineLength,
            lineThickness: boldLineThickness
          )
        )
        
      case .scanning:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: headerTextColor,
            background: cameraBackgroundColor ?? W3WColor.darkBlueAlpha60,
            line: successLineColor
          ),
          styles: W3WStyles(
            cornerRadius: withCornerRadius ? W3WCornerRadius(value: boldLineThickness.value / 2.0) : 0.0,
            fonts: fonts,
            textAlignment: W3WTextAlignment(value: .center),
            padding: padding ?? W3WPadding(value: -boldLineThickness.value / 2.0),
            rowHeight: boldLineLength,
            lineThickness: boldLineThickness
          )
        )
        
      case .scanned:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: headerTextColor,
            background: cameraBackgroundColor ?? W3WColor.darkBlueAlpha60,
            line: defaultLineColor
          ),
          styles: W3WStyles(
            cornerRadius: withCornerRadius ? W3WCornerRadius(value: defaultLineThickness.value / 2.0) : 0.0,
            fonts: fonts,
            textAlignment: W3WTextAlignment(value: .left),
            padding: padding ?? W3WPadding(value: -defaultLineThickness.value / 2.0),
            rowHeight: defaultLineLength,
            lineThickness: defaultLineThickness
          )
        )
        
      case .error:
        scheme = W3WScheme(
          colors: W3WColors(
            foreground: errorTextColor,
            background: cameraBackgroundColor ?? W3WColor.darkBlueAlpha60,
            line: errorLineColor
          ),
          styles: W3WStyles(
            cornerRadius: withCornerRadius ? W3WCornerRadius(value: boldLineThickness.value / 2.0) : 0.0,
            fonts: fonts,
            textAlignment: W3WTextAlignment(value: .left),
            padding: padding ?? W3WPadding(value: -boldLineThickness.value / 2.0),
            rowHeight: boldLineLength,
            lineThickness: boldLineThickness
          )
        )
      }
      resultTheme[state.setType] = scheme
    }
    return resultTheme
  }
}
