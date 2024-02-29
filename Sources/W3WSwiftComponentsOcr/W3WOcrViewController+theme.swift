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
    theme = theme?.withOcrStateSchemes()
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
