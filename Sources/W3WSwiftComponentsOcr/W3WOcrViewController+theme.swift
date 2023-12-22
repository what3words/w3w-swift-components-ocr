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
        scheme = W3WScheme(colors: W3WColors(foreground: W3WColor(uiColor: W3WSettings.ocrPrimaryTextColor), line: W3WColor(uiColor: .white)),
                           styles: W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 3.0),
                                             fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                             padding: W3WPadding(insets: .zero),
                                             rowHeight: W3WRowHeight(floatLiteral: 24.0),
                                             lineThickness: W3WLineThickness(floatLiteral: 6.0)))
      case .detecting:
        scheme = W3WScheme(colors: W3WColors(foreground: W3WColor(uiColor: W3WSettings.ocrPrimaryTextColor), line: W3WColor(uiColor: .white)),
                           styles: W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                             fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                             padding: W3WPadding(insets: .zero),
                                             rowHeight: W3WRowHeight(floatLiteral: 48.0),
                                             lineThickness: W3WLineThickness(floatLiteral: 12.0)))
      case .scanning:
        scheme = W3WScheme(colors: W3WColors(foreground: W3WColor(uiColor: W3WSettings.ocrPrimaryTextColor), line: W3WColor(uiColor: W3WSettings.ocrTargetSuccess)),
                           styles: W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                             fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                             padding: W3WPadding(insets: .zero),
                                             rowHeight: W3WRowHeight(floatLiteral: 48.0),
                                             lineThickness: W3WLineThickness(floatLiteral: 12.0)))
      case .scanned:
        scheme = W3WScheme(colors: W3WColors(foreground: W3WColor(uiColor: W3WSettings.ocrPrimaryGreyTextColor), line: W3WColor(uiColor: .white)),
                           styles: W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 3.0),
                                             fonts: W3WFonts(font: .systemFont(ofSize: 14.0, weight: .regular)),
                                             padding: W3WPadding(insets: .zero),
                                             rowHeight: W3WRowHeight(floatLiteral: 24.0),
                                             lineThickness: W3WLineThickness(floatLiteral: 6.0)))
      case .error:
        scheme = W3WScheme(colors: W3WColors(foreground: W3WColor(uiColor: W3WSettings.ocrPrimaryTextColor), line: W3WColor(uiColor: W3WSettings.ocrTargetFailed)),
                           styles: W3WStyles(cornerRadius: W3WCornerRadius(floatLiteral: 6.0),
                                             fonts: W3WFonts(font: .systemFont(ofSize: 17.0, weight: .semibold)),
                                             padding: W3WPadding(insets: .zero),
                                             rowHeight: W3WRowHeight(floatLiteral: 48.0),
                                             lineThickness: W3WLineThickness(floatLiteral: 12.0)))
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
