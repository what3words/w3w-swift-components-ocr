//
//  W3WSingleLabelCellItem.swift
//  
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftCore
import W3WSwiftDesign

public struct W3WSingleLabelCellItem: Hashable {
  public let identifier: String
  public let text: String?
  public let scheme: W3WScheme?
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  public static func == (lhs: W3WSingleLabelCellItem, rhs: W3WSingleLabelCellItem) -> Bool {
    lhs.identifier == rhs.identifier
  }
}

public extension W3WSingleLabelCellItem {
  init(ocrState: W3WOcrState, theme: W3WTheme?, resultIsEmpty: Bool = true, translations: W3WTranslationsProtocol) {
    var targetState = ocrState
    if !resultIsEmpty {
      targetState = .scanned
    }
    switch targetState {
    case .idle:
      text = translations.get(id: "ocr_scan_3wa")
      //text = LanguageStrings.localized(key: "ocr_scan_3wa")
    case .detecting:
      text = translations.get(id: "scan_state_detecting")
      //text = LanguageStrings.localized(key: "scan_state_detecting")
    case .scanning:
      text = translations.get(id: "ocr_scanning")
      //text = LanguageStrings.localized(key: "ocr_scanning")
    case .scanned:
      text = translations.get(id: "scan_state_found")
      //text = LanguageStrings.localized(key: "scan_state_found")
    default:
      //text = resultIsEmpty ? LanguageStrings.localized(key: "ocr_scan_3wa") : LanguageStrings.localized(key: "scan_state_found")
      text = resultIsEmpty ? translations.get(id: "ocr_scan_3wa") : translations.get(id: "scan_state_found")
    }
    scheme = theme?.getOcrScheme(state: targetState)?.with(background: .clear)
    identifier = targetState.rawValue
  }
}
