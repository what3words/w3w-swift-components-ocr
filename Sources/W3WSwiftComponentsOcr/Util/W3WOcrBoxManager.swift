//
//  W3WOcrBoxManager.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 25/06/2021.
//

import Foundation
import UIKit
import W3WSwiftCore
import W3WSwiftThemes


#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


@available(macCatalyst 14.0, *)
class W3WOcrBoxManager {
  
  // MARK: Vars
  
  /// colour for the text detection boxes
  var boxesColour:  UIColor = W3WCoreColor.white.uiColor
  
  /// style of the text detection boxes
  var boxStyle = W3WBoxStyle.outline
  
  /// camera crop coordinates of text areas
  var boxes = [CGRect]()
  
  /// array of UIView derived `W3WOcrBox` for showing text detection areas
  var highlightBoxes = [W3WOcrBox]()
  
  init() {
  }
  
  
  /// set the style for the text detection boxes
  /// - Parameters:
  ///     - boxStyle: the style to set the boxes to
  public func set(boxStyle: W3WBoxStyle) {
    self.boxStyle = boxStyle
    for box in highlightBoxes {
      box.set(style: boxStyle)
    }
  }
  
  
  /// get the style for the text detection boxes
  /// - Returns: the style being used for text detection boxes
  public func getBoxStyle() -> W3WBoxStyle {
    return boxStyle
  }
  
  
  /// remove all text detection boxes from the view
  func removeBoxes() {
    DispatchQueue.main.async {
      while self.highlightBoxes.count > 0 {
        if let box = self.highlightBoxes.first {
          DispatchQueue.main.async {
            box.removeFromSuperview()
          }
          self.highlightBoxes.removeFirst()
        }
      }
    }
  }
  
  
  // MARK: Animate Boxes
  
  
  /// update and animate text detection boxes
  /// - Parameters:
  ///     - w3wRect: array of rectangles defining where text might have been found in last image
  func update(boxes w3wRect: [W3WOcrRect], view: UIView, crop: CGRect?, maths: W3WOcrCoordinateMaths) {
    
    // convert `[W3WOcrRect]` to `[CGRect]` and skip any boxes with origin zero
    boxes = []
    for w3wbox in w3wRect {
      if !(w3wbox.x == 0 || w3wbox.y == 0) {
        boxes.append(CGRect(x: w3wbox.x, y: w3wbox.y, width: w3wbox.width, height: w3wbox.height))
      }
    }
    
    // update/animate W3WOcrBox'es coordinates to the most recent values
    DispatchQueue.main.async { [self] in
      
      // sort the boxes by geometry topleft to bottom right in order to match them with the values in 'highlightBoxes`
      self.boxes = boxes.sorted(by: { a,b in a.origin.y < b.origin.y })
      highlightBoxes.sort(by: { a,b in a.frame.origin.y < b.frame.origin.y })
      
      // find the count of the larger array `highlightBoxes` or `boxes`
      let max = boxes.count > highlightBoxes.count ? boxes.count : highlightBoxes.count
      
      // loop through all boxes, creating, deleting or updating them one at a time
      for i in 0...max {
        
        // update box position if `highlightBoxes[i]` matches with a `boxes[i]`
        if i < highlightBoxes.count && i < boxes.count {
          view.bringSubviewToFront(highlightBoxes[i])
          UIView.animate(withDuration: 0.3) {
            if crop != nil {
              if self.boxes[i].origin == CGPoint.zero {
                self.highlightBoxes[i].set(frame: CGRect(x: -10000.0, y: -10000.0, width: 10.0, height: 10.0))
              } else {
                let rectForView = maths.convertToCrop(rect: self.boxes[i])
                self.highlightBoxes[i].set(frame: rectForView)
              }
            } else {
              //if let t = cropTransform {
              self.highlightBoxes[i].set(frame: maths.convertToCrop(rect: self.boxes[i]))
              //}
            }
          }
        }
        
        // if we need a new highlightbox for the screen, then create one
        if i >= highlightBoxes.count && i < boxes.count && boxes[i].origin != CGPoint.zero {
          let rectForView = maths.convertToCrop(rect: boxes[i]).intersection(crop ?? view.bounds)
          let box = W3WOcrBox(frame: rectForView)
          box.style = self.boxStyle
          view.addSubview(box)
          view.bringSubviewToFront(box)
          highlightBoxes.append(box)
        }
        
        // if a highlight box is no longer needed then remove it
        if (i < highlightBoxes.count && i >= boxes.count) {
          if highlightBoxes[i].readyToDie() {
            highlightBoxes[i].removeFromSuperview()
            highlightBoxes.remove(at: i)
          }
        }
      }
    }
  }
  
  
  
  // MARK: Utility
  
  
  /// calculate the distance between two CGPoints
  func distance(a: CGPoint, b: CGPoint) -> CGFloat {
    return sqrt(pow(a.x - b.x, 2.0)+pow(a.y - b.y, 2.0))
  }
  
  
  /// calculate the distance between a CGPoint and a CGRect
  func distance(from: CGPoint, toCenterOf: CGRect) -> CGFloat {
    let center = CGPoint(x: toCenterOf.midX, y: toCenterOf.midY)
    return sqrt(pow(from.x - center.x, 2.0)+pow(from.y - center.y, 2.0))
  }
  
  
  /// calculate the distance between two CGRects
  func distance(fromCenterOf: CGRect, toCenterOf: CGRect) -> CGFloat {
    let center1 = CGPoint(x: fromCenterOf.midX, y: fromCenterOf.midY)
    let center2 = CGPoint(x: toCenterOf.midX, y: toCenterOf.midY)
    return sqrt(pow(center1.x - center2.x, 2.0)+pow(center1.y - center2.y, 2.0))
  }
  
  
}

//#endif // W3WOcrSdk
