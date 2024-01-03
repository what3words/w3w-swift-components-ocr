//
//  W3WOcrView.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

import Foundation
import UIKit
import W3WSwiftCore

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


/// a basic ocr scan view to display a cropped area target and shaded background
@available(macCatalyst 14.0, *)
public class W3WOcrView: W3WOcrBasicView {
  
  // background layers
  let backgroundLayer = W3WOcrBackgroundLayer()
  let viewfinderLayer = W3WOcrViewfinderLayer()
  
  // logic to control the text detection boxes
  let boxManager = W3WOcrBoxManager()
  
  /// crop region on screen, should mirror the corp region in the camera
  var crop = CGRect.zero
  
  // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
  var debugImage = UIImageView()
  var newImage: (CGImage) -> () = { _ in }
  
  
#if targetEnvironment(simulator)
  var debugCrop = true
  var debugImageInCrop = true
  var frameCount = 10
#else
  var debugCrop = false
  var debugImageInCrop = false
#endif
  
  
  // MARK: Init
  
  
  /// a basic ocr scan view to display a cropped area target and shaded background
  override public init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  
  /// a basic ocr scan view to display a cropped area target and shaded background
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  override func configure() {
    super.configure()
    
    recalculateAndPositionLayers()
    
    layer.addSublayer(backgroundLayer)
    layer.addSublayer(viewfinderLayer)
    if debugCrop {
      addSubview(debugImage)
    }
  }
  
  
  // MARK: Accessors
  
  public func set(crop: CGRect) {
    self.crop = CGRect(x: trunc(crop.origin.x), y: trunc(crop.origin.y), width: trunc(crop.size.width), height: trunc(crop.size.height))
    recalculateAndPositionLayers()
    
    camera?.onFrameInfo = { [weak self] info in
      self?.update(boxes: info.boxes)
    }
  }
  
  
  public func set(lineColor: UIColor, lineGap: CGFloat) {
    viewfinderLayer.set(color: lineColor, gap: lineGap)
  }
  
  
  /// set the style for the text detection boxes
  /// - Parameters:
  ///     - boxStyle: the style to set the boxes to
  public func set(boxStyle: W3WBoxStyle) {
    boxManager.set(boxStyle: boxStyle)
  }
  
  
  /// get the style for the text detection boxes
  public func getBoxStyle() -> W3WBoxStyle {
    boxManager.getBoxStyle()
  }
  
  
  public func update(boxes: [W3WOcrRect]) {
    W3WOcrThread.runOnMain {
      self.boxManager.update(boxes: boxes, view: self, crop: self.crop, maths: self.maths)
    }
  }
  
  
  /// remove all stray text detection boxes
  func removeBoxes() {
    boxManager.removeBoxes()
  }
  
  
  // MARK: UIView stuff
  
  func recalculateAndPositionLayers() {
    maths?.configureTransforms()
    
    camera?.set(crop: maths.convertToCamera(view: crop))
    
    backgroundLayer.frame = bounds
    backgroundLayer.set(crop: crop)
    viewfinderLayer.frame = bounds
    viewfinderLayer.set(crop: crop)
    
    if debugCrop {
#if targetEnvironment(simulator)
      if frameCount > 5 {
        frameCount = 0
        if let cgimage = camera?.imageProcessor.fakeImages.makeRandomThreeWordAddressImage(rect: crop) {
          debugImage.image = UIImage(cgImage: cgimage)
        }
      } else {
        frameCount += 1
      }
#endif
      if debugImageInCrop {
        debugImage.frame = crop.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
      } else {
        debugImage.frame = CGRect(origin: CGPoint(x: 32.0, y: frame.height - debugImage.frame.height - 32.0), size: CGSize(width: crop.size.width, height: crop.size.height))
      }
    }
  }
  
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    recalculateAndPositionLayers()
  }
  
}

