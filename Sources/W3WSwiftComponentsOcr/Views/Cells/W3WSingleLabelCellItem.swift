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
  init(ocrState: W3WOcrState, theme: W3WTheme?, resultIsEmpty: Bool = true) {
    switch ocrState {
    case .idle:
      text = W3WTranslations.main.translate(key: "ocr_scan_3wa")
    case .detecting:
      text = W3WTranslations.main.translate(key: "scan_state_detecting")
    case .scanning:
      text = W3WTranslations.main.translate(key: "ocr_scanning")
    case .scanned:
      text = W3WTranslations.main.translate(key: "scan_state_found")
    default:
      text = resultIsEmpty ? W3WTranslations.main.translate(key: "ocr_scan_3wa") : W3WTranslations.main.translate(key: "scan_state_found")
    }
    scheme = theme?.getOcrScheme(state: ocrState)
    identifier = ocrState.rawValue
  }
}
