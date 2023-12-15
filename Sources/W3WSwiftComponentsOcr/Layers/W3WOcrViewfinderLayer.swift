//
//  W3WOcrBackgroundLayer.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit
import W3WSwiftApi


/// draw target lines around the camera crop area, in a particular colour, as a rectangle or just corners as defined by `gapFactor`
class W3WOcrViewfinderLayer: CAShapeLayer {
  
  /// user defined camera crop
  var crop: CGRect = .zero

  /// user defined lines color
  var color: UIColor = W3WSettings.ocrTargetColor
  
  /// user defined lines width
  var width: CGFloat = W3WSettings.ocrViewfinderLineWidth
  
  /// user defined lines length
  var lineLength: CGFloat?
  
  /// user defined lines inset
  var inset: CGFloat = W3WSettings.ocrViewfinderLineWidth / 2
  
  /// user defined lines corner radius
  var curveRadius: CGFloat?
  
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
  
  
  /// draw target lines around the camera crop area as a rectangle
  func set(crop: CGRect) {
    self.crop = crop
    redrawLines()
  }
  
  /// draw target lines in a particular colour
  func setLineColor(_ color: UIColor) {
    self.color = color
    strokeColor = color.cgColor
  }
  
  /// draw target lines with corners as defined by `gapFactor`
  func setGap(_ gap: CGFloat) {
    self.gapFactor = gap
    redrawLines()
  }
  
  /// draw target lines with particular line width
  func setLineWidth(_ width: CGFloat) {
    self.width = width
    lineWidth = width
    redrawLines()
  }
  
  /// draw target lines with particular line length
  func setLineLength(_ length: CGFloat) {
    self.lineLength = length
    redrawLines()
  }
  
  /// draw target lines with particular inset
  func setLineInset(_ inset: CGFloat) {
    self.inset = inset
    redrawLines()
  }
  
  /// draw target lines with particular line corner radius
  func setLineCurveRadius(_ radius: CGFloat) {
    self.curveRadius = radius
    redrawLines()
  }
  
  /// redraw target lines, should be called whenever there is a change effecting lines frame
  func redrawLines(animate: Bool = false) {
    let oldTargetLayerPath = targetLayerPath

    targetLayerPath = UIBezierPath()
    
    // determine sizes
    var cornerLengthHorizontal = lineLength ?? min(crop.height, crop.width) * 4.0 / 11.0
    var cornerLengthVertical   = cornerLengthHorizontal
    
    // calculate gap
    cornerLengthVertical   = lerp(a: cornerLengthVertical, b: crop.height * 0.5, factor: 1.0 - gapFactor)
    cornerLengthHorizontal = lerp(a: cornerLengthHorizontal, b: crop.width * 0.5, factor: 1.0 - gapFactor)
    
    // top left
    targetLayerPath.move(to: CGPoint(   x: crop.minX + inset, y: crop.minY + inset - width / 2))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + inset, y: crop.minY + inset - width / 2 + cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: crop.minX + inset - width / 2, y: crop.minY + inset))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + inset - width / 2 + cornerLengthHorizontal, y: crop.minY + inset))
    if let curveRadius = curveRadius {
      let verticalRoundRect = CGRect(x: crop.minX + inset, y: crop.minY + inset - width / 2 + cornerLengthVertical - curveRadius, width: 0.1, height: width)
      targetLayerPath.append(UIBezierPath(roundedRect: verticalRoundRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
      let horizontalRoundRect = CGRect(x: crop.minX + inset - width / 2 + cornerLengthHorizontal - curveRadius, y: crop.minY + inset, width: width, height: 0.1)
      targetLayerPath.append(UIBezierPath(roundedRect: horizontalRoundRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
    }
    
    // top right
    targetLayerPath.move(to: CGPoint(   x: crop.minX + crop.width - inset, y: crop.minY + inset - width / 2))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + crop.width - inset, y: crop.minY + inset - width / 2 + cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: crop.minX + crop.width - inset + width / 2, y: crop.minY + inset))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + crop.width - inset + width / 2 - cornerLengthHorizontal, y: crop.minY + inset))
    if let curveRadius = curveRadius {
      let verticalRoundRect = CGRect(x: crop.minX + crop.width - inset, y: crop.minY + inset - width / 2 + cornerLengthVertical - curveRadius, width: 0.1, height: width)
      targetLayerPath.append(UIBezierPath(roundedRect: verticalRoundRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
      let horizontalRoundRect = CGRect(x: crop.minX + crop.width - inset + width / 2 - cornerLengthHorizontal - curveRadius, y: crop.minY + inset, width: width, height: 0.1)
      targetLayerPath.append(UIBezierPath(roundedRect: horizontalRoundRect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
    }
    
    // bottom left
    targetLayerPath.move(to: CGPoint(   x: crop.minX + inset, y: crop.maxY - inset + width / 2))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + inset, y: crop.maxY - inset + width / 2 - cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: crop.minX + inset - width / 2, y: crop.maxY - inset))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + inset - width / 2 + cornerLengthHorizontal, y: crop.maxY - inset))
    if let curveRadius = curveRadius {
      let verticalRoundRect = CGRect(x: crop.minX + inset, y: crop.maxY - inset + width / 2 - cornerLengthVertical - curveRadius, width: 0.1, height: width)
      targetLayerPath.append(UIBezierPath(roundedRect: verticalRoundRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
      let horizontalRoundRect = CGRect(x: crop.minX + inset - width / 2 + cornerLengthHorizontal - curveRadius, y: crop.maxY - inset, width: width, height: 0.1)
      targetLayerPath.append(UIBezierPath(roundedRect: horizontalRoundRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
    }
    
    // bottom right
    targetLayerPath.move(to: CGPoint(   x: crop.minX + crop.width - inset, y: crop.maxY - inset + width / 2))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + crop.width - inset, y: crop.maxY - inset + width / 2 - cornerLengthVertical))
    targetLayerPath.move(to: CGPoint(   x: crop.minX + crop.width - inset + width / 2, y: crop.maxY - inset))
    targetLayerPath.addLine(to: CGPoint(x: crop.minX + crop.width - inset + width / 2 - cornerLengthHorizontal, y: crop.maxY - inset))
    if let curveRadius = curveRadius {
      let verticalRoundRect = CGRect(x: crop.minX + crop.width - inset, y: crop.maxY - inset + width / 2 - cornerLengthVertical - curveRadius, width: 0.1, height: width)
      targetLayerPath.append(UIBezierPath(roundedRect: verticalRoundRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
      let horizontalRoundRect = CGRect(x: crop.minX + crop.width - inset + width / 2 - cornerLengthHorizontal - curveRadius, y: crop.maxY - inset, width: width, height: 0.1)
      targetLayerPath.append(UIBezierPath(roundedRect: horizontalRoundRect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: curveRadius, height: curveRadius)))
    }
    
    // set the path
    path = targetLayerPath.cgPath

    if animate {
      // animate the change
      gapAnimation = CABasicAnimation(keyPath: "path")
      gapAnimation.fromValue = oldTargetLayerPath?.cgPath
      gapAnimation.toValue = targetLayerPath.cgPath
      gapAnimation.duration = 0.3
      gapAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)   //CAMediaTimingFunction(controlPoints: 1.0, 0.0, 0.0, 1.0)
      add(gapAnimation, forKey: nil)
    }
  }
  
  /// basic lerp function
  public func lerp(a: CGFloat, b: CGFloat, factor: CGFloat) -> CGFloat {
    return a + (factor * (b - a))
  }
}


#endif
