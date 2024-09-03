//
//  File.swift
//  
//
//  Created by Dave Duprey on 08/06/2021.
//

#if canImport(UIKit) && !os(watchOS)

import Foundation
import UIKit
import W3WSwiftCore
import W3WSwiftThemes


/// A UILabel for the W3WOcrView to display a three word address
class W3WOcrScannerAddressLabel: UILabel {
  
  /// maximum address size
  var maxWidth = W3WSettings.ocrAddressLabelMaxWidth

  
  // MARK: Init
  

  /// A UILabel for the W3WOcrView to display a three word address
  init(words: String, maxWidth: CGFloat, frame: CGRect) {
    super.init(frame: frame)
    set(words: words)
    self.maxWidth = maxWidth
  }
  
  
  /// A UILabel for the W3WOcrView to display a three word address
  override init(frame: CGRect) {
    super.init(frame: frame)
    set(words: "")
  }
  
  
  /// A UILabel for the W3WOcrView to display a three word address
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    set(words: "")
  }
  
  
  /// does the work of actually positioning and colouring the label
  func reposition(origin: CGPoint) {
    backgroundColor = W3WCoreColor.green50.uiColor
    textColor = W3WCoreColor.black.uiColor
    textAlignment = .center
    minimumScaleFactor = 0.4
    adjustsFontSizeToFitWidth = true
    sizeToFit()

    frame = CGRect(origin: origin, size: CGSize(width: min(frame.size.width + 16.0, maxWidth), height: min(frame.size.height + 16.0, W3WSettings.ocrAddressLabelMaxHeight)))
  }


  // MARK: Accessors
  
  
  /// set the text to show in the label
  func set(words: String) {
    text = "///" + words.replacingOccurrences(of: "/", with: "")
    reposition(origin: frame.origin)
  }
  
  

}

#endif
