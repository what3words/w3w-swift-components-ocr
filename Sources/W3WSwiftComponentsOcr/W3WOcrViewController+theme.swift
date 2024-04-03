//
//  W3WOcrViewController+theme.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 19/12/2023.
//

#if canImport(UIKit)
import UIKit
import W3WSwiftCore
import W3WSwiftThemes

public extension W3WTheme {
  func getOcrScheme(state: W3WOcrState) -> W3WScheme? {
    return self[state.setType]
  }
}

public extension W3WSetTypes {
  static let ocrIdle: W3WSetTypes = "ocr.idle"
  static let ocrDetecting: W3WSetTypes = "ocr.detecting"
  static let ocrScanning: W3WSetTypes = "ocr.scanning"
  static let ocrScanned: W3WSetTypes = "ocr.scanned"
  static let ocrError: W3WSetTypes = "ocr.error"
}

public extension W3WOcrState {
  var setType: W3WSetTypes {
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
#endif
