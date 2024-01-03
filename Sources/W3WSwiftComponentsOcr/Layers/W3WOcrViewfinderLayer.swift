//
//  W3WOcrBackgroundLayer.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit
import W3WSwiftCore


/// draw target lines around the camera crop area, in a particular colour, as a rectangle or just corners as defined by `gapFactor`
class W3WOcrViewfinderLayer: CAShapeLayer {

  var color: UIColor = W3WSettings.ocrTargetColor

  /// bezier for target layer
  var targetLayerPath: UIBezierPath!

  /// animation for the target gap
  var gapAnimation: CABasicAnimation!

  /// how much of a gap to show
  var gapFactor = CGFloat(1.0)

  
  /// set the gap and color
  func set(color: UIColor, gap: CGFloat) {
    self.color = color
    self.gapFactor = gap
    needsDisplay()
  }
  
  
  /// draw target lines around the camera crop area, in a particular colour, as a rectangle or just corners as defined by `gapFactor`
  func set(crop: CGRect) {
    let oldTargetLayerPath = targetLayerPath

    targetLayerPath = UIBezierPath()
    
    // determine sizes
    var cornerLengthHorizontal = min(crop.height, crop.width) * 4.0 / 11.0
    var cornerLengthVertical   = cornerLengthHorizontal
    
    // calculate gap
    cornerLengthVertical   = lerp(a: cornerLengthVertical, b: crop.height * 0.5, factor: 1.0 - gapFactor)
    cornerLengthHorizontal = lerp(a: cornerLengthHorizontal, b: crop.width * 0.5, factor: 1.0 - gapFactor)
    
    // inset the crop by the width of the lines so the lines are drawn just inside the box
    let inset = W3WSettings.ocrViewfinderLineWidth / 2.0
    let insetCrop = CGRect(x: crop.minX + inset, y: crop.minY + inset, width: crop.width - inset * 2.0, height: crop.height - inset * 2.0)
    
    // top left
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x, y: insetCrop.origin.y))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x, y: insetCrop.origin.y + cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x - inset, y: insetCrop.origin.y))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + cornerLengthHorizontal, y: insetCrop.origin.y))
    
    // top right
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x + insetCrop.width, y: insetCrop.origin.y))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + insetCrop.width, y: insetCrop.origin.y + cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x + insetCrop.width + inset, y: insetCrop.origin.y))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + insetCrop.width - cornerLengthHorizontal, y: insetCrop.origin.y))
    
    // bottom left
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x, y: insetCrop.origin.y + insetCrop.height))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x, y: insetCrop.origin.y + insetCrop.height - cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x - inset, y: insetCrop.origin.y + insetCrop.height))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + cornerLengthHorizontal, y: insetCrop.origin.y + insetCrop.height))
    
    // bottom right
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x + insetCrop.width, y: insetCrop.origin.y + insetCrop.height))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + insetCrop.width, y: insetCrop.origin.y + insetCrop.height - cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: insetCrop.origin.x + insetCrop.width + inset, y: insetCrop.origin.y + insetCrop.height))
    targetLayerPath.addLine(to: CGPoint(x: insetCrop.origin.x + insetCrop.width - cornerLengthHorizontal, y: insetCrop.origin.y + insetCrop.height))
    
    // colour and width
    strokeColor = color.cgColor
    lineWidth   = W3WSettings.ocrViewfinderLineWidth
    
    // set the path
    path = targetLayerPath.cgPath

    // animate the change
    gapAnimation = CABasicAnimation(keyPath: "path")
    gapAnimation.fromValue = oldTargetLayerPath?.cgPath
    gapAnimation.toValue = targetLayerPath.cgPath
    gapAnimation.duration = 0.3
    gapAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)   //CAMediaTimingFunction(controlPoints: 1.0, 0.0, 0.0, 1.0)
    add(gapAnimation, forKey: nil)
  }
  

  /// basic lerp function
  public func lerp(a: CGFloat, b: CGFloat, factor: CGFloat) -> CGFloat {
    return a + (factor * (b - a))
  }

  
}


#endif
