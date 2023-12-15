//
//  W3WOcrTheme.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 15/12/2023.
//

import Foundation

public struct W3WOcrTheme {
  public var idleStyle: W3WOcrStyle = .defaultIdleStyle
  public var detectingStyle: W3WOcrStyle = .defaultDetectingStyle
  public var scanningStyle: W3WOcrStyle = .defaultScanningStyle
  public var errorStyle: W3WOcrStyle = .defaultErrorStyle
}

extension W3WOcrTheme{
  static var defaultTheme: W3WOcrTheme {
    return W3WOcrTheme()
  }
}
