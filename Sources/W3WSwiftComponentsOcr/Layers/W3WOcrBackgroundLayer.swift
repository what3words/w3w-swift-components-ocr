//
//  W3WOcrBackgroundLayer.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit
import W3WSwiftApi


/// draws a translucent background with a hole cut out for the camera crop
class W3WOcrBackgroundLayer: CAShapeLayer {

  var color: UIColor = W3WSettings.ocrOverlayColour


  /// set the colour of this background
  func set(color: UIColor) {
    self.color = color
  }
  
  
  /// draws a translucent background with a hole cut out for the camera crop
  func set(crop: CGRect) {
    
    // figure out sizes
    let outset     = W3WSettings.ocrViewfinderInset
    let outsetCrop = CGRect(x: crop.origin.x - outset, y: crop.origin.y - outset, width: crop.size.width + outset * 2.0, height: crop.size.height + outset * 2.0)
    
    // make four sections
    let top = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: outsetCrop.origin.y))
    let left = UIBezierPath(rect: CGRect(x: 0.0, y: outsetCrop.origin.y, width: outsetCrop.origin.x, height: outsetCrop.size.height))
    let right = UIBezierPath(rect: CGRect(x: outsetCrop.origin.x + outsetCrop.size.width, y: outsetCrop.origin.y, width: frame.size.width - outsetCrop.origin.x + outsetCrop.size.width, height: outsetCrop.size.height))
    let bottom = UIBezierPath(rect: CGRect(x: 0.0, y: outsetCrop.origin.y + outsetCrop.size.height, width: frame.size.width, height: frame.size.height - (outsetCrop.origin.y + outsetCrop.size.height)))
    
    // put all the sections into one path
    top.append(left)
    top.append(right)
    top.append(bottom)
    
    // set the colour for the background
    fillColor = color.cgColor
    
    // set the path
    path = top.cgPath
  }
  
}

#endif
