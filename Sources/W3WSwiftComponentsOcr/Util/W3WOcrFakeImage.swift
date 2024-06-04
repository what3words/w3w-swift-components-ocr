//
//  W3WOcrFakeImage.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 26/06/2021.
//

import Foundation
import AVKit
import CoreGraphics
import W3WSwiftCore


/// makes fake images for iOS simulator as it doesn't have access to a camera (as of this writing)
class W3WOcrFakeImages {

  let addresses = W3WSettings.simulated3WordAddresses

  
  /// gets a random three word address
  func random3wa() -> String {
    let index = Int(NSDate().timeIntervalSince1970 / 5.0) % (addresses.count)
    let words = addresses[index]
    return words
  }
  
  
  /// makes a simulated three word address image for debugging
  func makeRandomThreeWordAddressImage(rect: CGRect) -> CGImage? {
    
    var image: CGImage?

    #if canImport(UIKit) && !os(watchOS)
    let nameLabel = UILabel(frame: rect)
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = UIColor(red: varyingFactor(seed: 1.0), green: varyingFactor(seed: 1.0), blue: varyingFactor(seed: 1.0), alpha: 1.0)
    nameLabel.textColor = .black
    nameLabel.text = random3wa()
    nameLabel.font = UIFont.boldSystemFont(ofSize: rect.width * 0.1 * varyingFactor(seed: Double(nameLabel.text?.count ?? 0)))
    UIGraphicsBeginImageContext(rect.size)

    if let currentContext = UIGraphicsGetCurrentContext() {
      nameLabel.layer.render(in: currentContext)
      let nameImage = UIGraphicsGetImageFromCurrentImageContext()
      image = nameImage?.cgImage
    }

    UIGraphicsEndImageContext()
    #endif
    
    return image
  }

  
  /// make a multiplication factor to slowly zoom a variable based on a real world clock
  func varyingFactor(seed: Double) -> CGFloat {
    let i = Double(NSDate().timeIntervalSince1970 / 2.0 + seed)
    return CGFloat(cos(i) * 0.25 + 0.75)
  }
  
}
  
