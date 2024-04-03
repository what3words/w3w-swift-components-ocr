//
//  W3WOcrCoordinateMaths.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

import Foundation
import AVKit

//#if canImport(W3WOcrSdk)


/// keeps track of the various coordinate systems
@available(macCatalyst 14.0, *)
class W3WOcrCoordinateMaths {
  
  /// matrix to convert between camera coordinates and view coordinates
  var layerToCameraTransform = CGAffineTransform.identity

  /// matrix to convert between camera coordinates and view coordinates
  //var cameraToLayerTransform = CGAffineTransform.identity

  /// matrix to convert camera cropped image coordinates to view coordinates
  var cropTransform = CGAffineTransform.identity
  
  var layerToCameraScale = CGFloat(1.0)
  
  weak var videoPreviewLayer: AVCaptureVideoPreviewLayer!
  
  weak var camera: W3WOcrCamera?

  
  /// keeps track of the various coordinate systems
  init(layer: AVCaptureVideoPreviewLayer, camera: W3WOcrCamera?) {
    self.videoPreviewLayer = layer
    self.camera = camera
  }
  

  // MARK: Convert Crop-Camera
  
  
  func convertToCamera(view: CGRect) -> CGRect {
    configureTransforms()
    
    let converted = view.applying(layerToCameraTransform)
    return converted
  }
  
  
  func convertToCrop(rect: CGRect) -> CGRect {
    let converted = rect.applying(cropTransform)
    return converted
  }
  

  // MARK: Calculate Matricies

  
  /// calculate maticies, `cameraTransform` and `cropTransform` to use to convert
  /// between camera and view and crop coordinates
  func configureTransforms() {
    
    let (origin, opposite) = cameraPointsInLayerCoordinateSystem()
    let cameraRectInLayerCoords = makeOrienatedRectFromTwoPoints(p0: origin, p1: opposite)
    
    if let cameraResolution = camera?.getResolution() {
      
      let cameraAspectRatio   = cameraResolution.width / cameraResolution.height
      let layerAspectRatio    = videoPreviewLayer.frame.width / videoPreviewLayer.frame.height
      if cameraAspectRatio > layerAspectRatio {
        layerToCameraScale = cameraResolution.height / videoPreviewLayer.frame.height
      } else {
        layerToCameraScale = cameraResolution.width / videoPreviewLayer.frame.width
      }
      
      layerToCameraTransform = CGAffineTransform.identity
        .scaledBy(x: layerToCameraScale, y: -layerToCameraScale)
        .translatedBy(x: -cameraRectInLayerCoords.origin.x, y: -cameraRectInLayerCoords.size.height - cameraRectInLayerCoords.origin.y)
    }
    
    if let crop = camera?.getCrop() {
      let viewCrop = crop.applying(layerToCameraTransform.inverted())
      cropTransform = CGAffineTransform.identity
        .translatedBy(x: viewCrop.origin.x, y: viewCrop.origin.y)
        .scaledBy(x: 1.0 / layerToCameraScale, y: 1.0 / layerToCameraScale)
    }
  }
  
  
  // MARK: Util
  
  
  func transform(from source: CGRect, to destination: CGRect) -> CGAffineTransform {
    let t = CGAffineTransform.identity
      .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
      .scaledBy(x: destination.width / source.width, y: destination.width / source.width)
    return t
  }
  
  
  func normalizeFromLayer(rect: CGRect) -> CGRect {
    return CGRect(
      x: rect.minX / videoPreviewLayer.bounds.width,
      y: rect.minY / videoPreviewLayer.bounds.height,
      width: rect.width / videoPreviewLayer.bounds.width,
      height: rect.height / videoPreviewLayer.bounds.height)
  }
  
  
//  func rotate(rect: CGRect, by: CGFloat, around: CGPoint) -> CGRect {
//    let transform = CGAffineTransform(translationX: around.x, y: around.y)
//    _ = transform.rotated(by: by)
//    _ = transform.translatedBy(x: -around.x, y: -around.y)
//
//    return rect.applying(transform)
//  }


  /// make a CGRect from two points, and make sure it is the right way up
  func makeOrienatedRectFromTwoPoints(p0: CGPoint, p1: CGPoint) -> CGRect {
    
    var origin = p0
    var opposite = p0
    
    if p0.x < p1.x {
      origin.x = p0.x
      opposite.x = p1.x
    } else {
      origin.x = p1.x
      opposite.x = p0.x
    }
    
    if p0.y < p1.y {
      origin.y = p0.y
      opposite.y = p1.y
    } else {
      origin.y = p1.y
      opposite.y = p0.y
    }

    return CGRect(origin: origin, size: CGSize(width: opposite.x - origin.x, height: opposite.y - origin.y))
  }
  
  

  /// returns where the view origin sits over the camera coordinate system
  func cameraPointsInLayerCoordinateSystem() -> (CGPoint, CGPoint) {
    var origin = CGPoint.zero
    var opposite = CGPoint(x: 1.0, y: 1.0)
        
    // firgure out which corner the origin is sitting at depending on camera orientation
    switch self.videoPreviewLayer.connection?.videoOrientation ?? .portrait {
    case .portrait:
      origin = CGPoint(x: 1.0, y: 1.0)
      opposite = CGPoint(x: 0.0, y: 0.0)
    case .portraitUpsideDown:
      origin = CGPoint(x: 0.0, y: 0.0)
      opposite = CGPoint(x: 1.0, y: 1.0)
    case .landscapeRight:
      origin = CGPoint(x: 0.0, y: 1.0)
      opposite = CGPoint(x: 1.0, y: 0.0)
    case .landscapeLeft:
      origin = CGPoint(x: 1.0, y: 0.0)
      opposite = CGPoint(x: 0.0, y: 1.0)
    default:
      break
    }
    
    if let o = cameraToLayer(normalizedPoint: origin) {
      origin = o
    }
    
    if let o = cameraToLayer(normalizedPoint: opposite) {
      opposite = o
    }
    
    return (origin, opposite)
  }
  
  
  // MARK: Coordinate Maths
  
  /// given a CGRect in camera coordinates, return the corresponding view coordinates
  /// - Parameters:
  ///     - rect: the rect in camera coordinates
  /// - Returns: view coordinates of the passed in camera coordinates
  func cameraToViewCoords(rect: CGRect) -> CGRect? {
    var retval = rect
    
    if let cameraResolution = camera?.getResolution() {
      let cameraRectNormalized = CGRect(
        x: (1.0 - rect.origin.y / cameraResolution.height) - rect.size.height / cameraResolution.height,
        y: (1.0 - rect.origin.x / cameraResolution.width) - rect.size.width / cameraResolution.width,
        width: rect.size.height / cameraResolution.height,
        height: rect.size.width / cameraResolution.width
      )
      if #available(macOS 10.15, *) {
        retval = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: cameraRectNormalized)
      }
    }
    
    return retval
  }
  
  
  /// given a CGPoint in camera coordinates, return the corresponding view coordinates
  /// - Parameters:
  ///     - point: the rect in camera coordinates
  /// - Returns: view coordinate of the passed in camera coordinate
  func cameraToLayer(point: CGPoint) -> CGPoint? {
    var retval = point
    
    if let resolution = camera?.getResolution() {
      let x = point.x / resolution.width
      let y = point.y / resolution.height
      if #available(macOS 10.15, *) {
        retval = videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: x, y: y))
      }
    }
    
    return retval
  }
  
  
  /// given a CGPoint in unit coordinate space [0.0 -> 1.0], return the corresponding view coordinates
  /// - Parameters:
  ///     - point: the point in unit coordinates [0.0 -> 1.0]
  /// - Returns: view coordinate of the passed in camera coordinate
  func cameraToLayer(normalizedPoint: CGPoint) -> CGPoint? {
    if #available(macOS 10.15, *) {
      return videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: normalizedPoint.x, y: normalizedPoint.y))
    }
    return .zero
  }
  
  
  /// given a CGPoint in view coordinate space, return the corresponding camera coordinates
  /// - Parameters:
  ///     - point: the point in view coordinates
  /// - Returns: camera coordinate of the passed in view coordinate
  func layerToCameraCoords(point: CGPoint) -> CGPoint? {
    //return videoPreviewLayer?.captureDevicePointConverted(fromLayerPoint: point)
    return videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: point)
  }
  
  
}


//#endif // W3WOcrSdk
