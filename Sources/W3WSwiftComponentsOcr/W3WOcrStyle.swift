//
//  W3WOcrStyle.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 14/12/2023.
//

import UIKit
import W3WSwiftApi

public struct W3WOcrStyle {
  public var viewFinderLineColor: UIColor?
  public var viewFinderLineWidth: CGFloat?
  public var viewFinderLineLength: CGFloat?
  public var viewFinderLineInset: CGFloat?
  public var viewFinderLineCurveRadius: CGFloat?
}

public extension W3WOcrStyle {
  static var defaultIdleStyle: W3WOcrStyle = .init(viewFinderLineColor: .white, viewFinderLineWidth: 6.0, viewFinderLineLength: 24.0, viewFinderLineInset: 0.0, viewFinderLineCurveRadius: 3.0)
  static var defaultDetectingStyle: W3WOcrStyle = .init(viewFinderLineColor: .white, viewFinderLineWidth: 12.0, viewFinderLineLength: 48.0, viewFinderLineInset: 0.0, viewFinderLineCurveRadius: 6.0)
  static var defaultScanningStyle: W3WOcrStyle = .init(viewFinderLineColor: W3WSettings.ocrTargetSuccess, viewFinderLineWidth: 12.0, viewFinderLineLength: 48.0, viewFinderLineInset: 0.0, viewFinderLineCurveRadius: 6.0)
  static var defaultErrorStyle: W3WOcrStyle = .init(viewFinderLineColor: W3WSettings.ocrTargetFailed, viewFinderLineWidth: 12.0, viewFinderLineLength: 48.0, viewFinderLineInset: 0.0, viewFinderLineCurveRadius: 6.0)
}
