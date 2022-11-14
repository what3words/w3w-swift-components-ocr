//
//  File.swift
//
//
//  Created by Dave Duprey on 29/09/2020.
//

#if canImport(UIKit)

import W3WSwiftApi
import UIKit


public extension W3WSettings {

  // colours
  static let ocrTextColor:            	  UIColor   = .white
  static let ocrTargetColor:              UIColor   = .white
  static let ocrBoxesColour:              UIColor   = .white
  static let ocrTextResultColour:         UIColor   = .black
  static let ocrOverlayColour:            UIColor   = UIColor.black.withAlphaComponent(0.6)
  static let ocrTargetSuccess:            UIColor   = #colorLiteral(red: 0.3705701232, green: 0.7888284326, blue: 0.5609446168, alpha: 1)
  static let ocrIconColour:               UIColor   = #colorLiteral(red: 0.8836055398, green: 0.1235802993, blue: 0.1483977437, alpha: 1)
  static let ocrIconBackground:           UIColor   = .white
  static let ocrTimoutBackground:     	  UIColor   = #colorLiteral(red: 0.1628443599, green: 0.2728673518, blue: 0.3541108966, alpha: 1).withAlphaComponent(0.5)
  
  // text
  static let ocrHintTextSize:             CGFloat   = 18.0
  
  // geometry settings
  static var ocrViewfinderRatioPortrait:  CGFloat   = 0.538
  static var ocrViewfinderRatioLandscape: CGFloat   = 0.274
  static let ocrViewfinderInset:          CGFloat   = 0.0
  static let ocrViewfinderLineWidth:      CGFloat   = 3.0
  static let ocrCropInset:                CGFloat   = 24.0
  static let ocrAddressLabelMaxWidth:     CGFloat   = 256.0
  static let ocrAddressLabelMaxHeight:    CGFloat   = 32.0

}

#endif
