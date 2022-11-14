//
//  W3WOcrBox.swift
//  TestOCR3
//
//  Created by Dave Duprey on 10/03/2021.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit
import W3WSwiftApi


/// the shape of the box
public enum W3WBoxStyle: String, CaseIterable {
  case smallBox = "Small Box"
  case outline = "OutLine"
  case corners = "Corners"
}


/// a box to show where text may be on a view
class W3WOcrBox : UIView {

  // MARK: Vars

  /// shape of the box
  var style = W3WBoxStyle.smallBox
  
  /// color of the box
  var color: UIColor = W3WSettings.ocrBoxesColour
  
  /// time to live
  var deathClock = CGFloat(0.2)
  
  /// how quickly life passes us by...
  let marchOfDeath = CGFloat(0.05)

  
  // MARK: Init


  /// a box to show where text may be on a view
  override init(frame: CGRect) {
    var newFrame = frame
    if !W3WOcrBox.isValid(frame: frame) {
      newFrame = CGRect.zero
    }
    super.init(frame: newFrame)
    
    position()
  }

  
  /// a box to show where text may be on a view
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = UIColor.clear
    position()
  }
  

  /// incitial configuration of this object, called from the init()s
  func position() {
    backgroundColor = UIColor.clear
  }

  
  // MARK: Accessors

  
  /// set the style of the box
  func set(style: W3WBoxStyle) {
    self.style = style
    updateGraphics()
  }
  
  
  /// checks if the given rectangle is inside of the current view.frame
  static func isValid(frame: CGRect) -> Bool {
    if !frame.origin.x.isNaN && !frame.origin.y.isNaN && !frame.size.width.isNaN && !frame.size.height.isNaN && frame.origin.x >= 0.0 && frame.origin.y >= 0.0 && frame.size.width >= 0.0 && frame.size.height >= 0.0 {
      return true
    } else {
      return false
    }
  }
  
  
  /// set the position of the box
  func set(frame: CGRect) {
    // if the frame has rational values then update the frame otherwise ignore
    if W3WOcrBox.isValid(frame: frame) {
      self.frame = frame
      updateGraphics()
    
    } else {
      print("textbox sizing error")
    }
  }
  


  /// determine if the box needs to die
  func readyToDie() -> Bool {
    deathClock = deathClock - marchOfDeath
    
    //updateGraphics()
    
    if deathClock <= 0.0 {
      return true
    } else {
      return false
    }
  }
  
  
  // MARK: Graphics
  
  
  /// redraw the box, update it's lifespan
  func updateGraphics() {

    // update the boxes lifespan
    deathClock = deathClock + marchOfDeath
    if deathClock > 1.0 {
      deathClock = 1.0
    }

    // indicate it needs a redraw
    setNeedsDisplay()
  }


  /// draw the box
  override func draw(_ rect: CGRect) {
    switch style {
      case .outline:
        morph(scale: 1.0, gap: 0.0, lineWidthFactor: 3.0)
      case .smallBox:
        morph(scale: 0.1, gap: 0.0, lineWidthFactor: 2.0)
      case .corners:
        morph(scale: 1.0, gap: 0.7, lineWidthFactor: 3.0)
    }
  }


  /// good old fashioned lerp function
  public func lerp(a: CGFloat, b: CGFloat, factor: CGFloat) -> CGFloat {
    return a + (factor * (b - a))
  }


  /// draw the box
  func morph(scale: CGFloat, gap: CGFloat, lineWidthFactor: CGFloat) {
    let aPath = UIBezierPath()

    // calculate the size
    var boxWidth  = scale * frame.size.width
    var boxHeight = scale * frame.size.height

    // enforce limits
    if boxWidth  < 20.0 { boxWidth  = CGFloat(20.0) }
    if boxHeight < 20.0 { boxHeight = CGFloat(20.0) }

    // interpolate between shapes based on factor
    boxWidth  = lerp(a: boxWidth, b: (boxWidth + boxHeight) / 2.0, factor: 1.0 - scale)
    boxHeight = lerp(a: boxHeight, b: (boxWidth + boxHeight) / 2.0, factor: 1.0 - scale)

    // calutale the gap size
    var horizontalGap = boxWidth  * gap
    var verticalGap   = boxHeight * gap

    // enforce gap limits
    if boxWidth  - horizontalGap < 40.0 { horizontalGap = boxWidth  - 40.0 }
    if boxHeight - verticalGap   < 40.0 { verticalGap   = boxHeight - 40.0 }

    // draw corner
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 - boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 - horizontalGap / 2.0,y: frame.size.height / 2.0 - boxHeight / 2.0))
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 + horizontalGap / 2.0,y: frame.size.height / 2.0 - boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 - boxHeight / 2.0))

    // draw corner
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 + boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 - horizontalGap / 2.0,y: frame.size.height / 2.0 + boxHeight / 2.0))
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 + horizontalGap / 2.0,y: frame.size.height / 2.0 + boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 + boxHeight / 2.0))

    // draw corner
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 - boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 - verticalGap / 2.0))
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 + verticalGap / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 - boxWidth / 2.0,     y: frame.size.height / 2.0 + boxHeight / 2.0))

    // draw corner
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 - boxHeight / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 - verticalGap / 2.0))
    aPath.move(to: CGPoint(   x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 + verticalGap / 2.0))
    aPath.addLine(to: CGPoint(x: frame.size.width / 2.0 + boxWidth / 2.0,     y: frame.size.height / 2.0 + boxHeight / 2.0))

    aPath.close()

    // set color and draw this thing
    color.withAlphaComponent(deathClock).set()
    aPath.lineWidth = deathClock * lineWidthFactor
    aPath.stroke()
  }
  
}

#endif
