//
//  File.swift
//  
//
//  Created by Dave Duprey on 16/06/2021.
//
#if !os(tvOS) && !os(watchOS)

import Foundation
import AVKit
import CoreGraphics

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk

/// handles AVCapture output and crops images
@available(macCatalyst 14.0, *)
class W3WCameraImageProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
   
  // MARK: Vars

  /// callback for any new images
  var onNewImage: (CGImage) -> () = { _ in }
  //var onNewVideoBuffer: (CMSampleBuffer) -> () = { _ in }
  
  /// orientaion of the camera
  var orientation: AVCaptureVideoOrientation = .portrait
  
  /// this monitors device orientation
  lazy var orientationObserver = W3WOcrOrientationObserver()
  
  /// resultution of the camera
  var resolution: CGSize?
  
  /// region to crop output images to
  var crop: CGRect?
  
  
  // MARK: Init

  override init() {
    super.init()

    self.orientation = orientationObserver.currentOrientationForCamera()
    
    orientationObserver.onNewOrientation = { [weak self] orientation in
      self?.orientation = orientation
    }
  }
  
  
  /// sets a crop for all returning images in camera coordinates
  /// - Parameters:
  ///     - crop: the region to crop images to, provided in camera coordinates
  public func set(crop: CGRect) {
    self.crop = crop
  }

  
  // MARK: AVCaptureVideoDataOutputSampleBufferDelegate


  /// called when a new image is aviaable from the camera
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    // make sure the orientation is correct
    connection.videoOrientation = orientation

    // crop the incoming image, and send to whomever is interested
    if let i = image(from: sampleBuffer, crop: crop) {
      onNewImage(i)
    }
  }
  

  // MARK: Util
  
  /// crop an image and return it as a CGImage
  /// - Parameters:
  ///     - buffer: image buffer from the camera
  ///     - crop: region to crop to
  /// - Returns: CGImage of the crop
  private func image(from buffer: CMSampleBuffer, crop: CGRect?) -> CGImage? {
    var image: CGImage?
    
    if let imageBuffer = CMSampleBufferGetImageBuffer(buffer) {
      var ciimage = CIImage(cvPixelBuffer: imageBuffer)
      resolution = CGSize(width: ciimage.extent.size.width, height: ciimage.extent.size.height)
      if let c = crop?.intersection(CGRect(origin: CGPoint.zero, size: resolution!)) {
        ciimage = ciimage.cropped(to: c)
      }
      
      if let cgImage = CIContext.init(options: nil).createCGImage(ciimage, from: ciimage.extent) {
        image = cgImage
      }
    }
    
    return image
  }
  
  
  // this makes the OCR work even under the iOS simulator
  #if targetEnvironment(simulator)
  var fakeImages = W3WOcrFakeImages()
  var timer: Timer?

  public func start() {
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.makeFakeFrame), userInfo: nil, repeats: true)
  }

  public func stop() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc
  func makeFakeFrame() {
    if let image = fakeImages.makeRandomThreeWordAddressImage(rect: crop ?? CGRect(x: 0.0, y: 0.0, width: 256.0, height: 256.0)) {
      self.onNewImage(image)
    }
  }

  
  #endif
  
}



#endif
