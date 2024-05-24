//
//  File.swift
//
//
//  Created by Dave Duprey on 29/09/2020.
//

#if canImport(UIKit)

import W3WSwiftCore
import UIKit


public extension W3WSettings {
  
  static var simulated3WordAddresses = ["maidy.toilatu.mūzdyq", "index.home.raft", "daring.lion.race", "майды.тойлату.мұздық", "oval.blast.improving", "form.monkey.employ"]
  
  // geometry settings
  static var ocrViewfinderRatioPortrait:  CGFloat   = 0.538
  static var ocrViewfinderRatioLandscape: CGFloat   = 0.274
  static let ocrViewfinderInset:          CGFloat   = 0.0
  static let ocrViewfinderLineWidth:      CGFloat   = 3.0
  static let ocrCropInset:                CGFloat   = 24.0
  static let ocrAddressLabelMaxWidth:     CGFloat   = 256.0
  static let ocrAddressLabelMaxHeight:    CGFloat   = 32.0

  static var bottomSafeArea: CGFloat {
    if #unavailable(iOS 15) {
      return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    } else {
      return UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
    }
  }
  
  static var topSafeArea: CGFloat {
    if #unavailable(iOS 15) {
      return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    } else {
      return UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0
    }
  }
}

#endif
