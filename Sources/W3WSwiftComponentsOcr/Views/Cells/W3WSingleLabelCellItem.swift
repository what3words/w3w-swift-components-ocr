//
//  W3WSingleLabelCellItem.swift
//  
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
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
    var targetState = ocrState
    if !resultIsEmpty {
      targetState = .scanned
    }
    switch targetState {
    case .idle:
      text = NSLocalizedString("ocr_scan_3wa", bundle: Bundle.module, comment: "")
    case .detecting:
      text = NSLocalizedString("scan_state_detecting", bundle: Bundle.module, comment: "")
    case .scanning:
      text = NSLocalizedString("ocr_scanning", bundle: Bundle.module, comment: "")
    case .scanned:
      text = NSLocalizedString("scan_state_found", bundle: Bundle.module, comment: "")
    default:
      text = ""
    }
    scheme = theme?.getOcrScheme(state: targetState)
    identifier = targetState.rawValue
  }
}
