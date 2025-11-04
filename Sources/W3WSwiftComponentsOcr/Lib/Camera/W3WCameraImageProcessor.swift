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

  /// resultution of the camera
  var resolution: CGSize?
  
  /// region to crop output images to
  var crop: CGRect = .zero
  
  
  /// sets a crop for all returning images in camera coordinates
  /// - Parameters:
  ///     - crop: the region to crop images to, provided in camera coordinates
  public func set(crop: CGRect) {
    self.crop = crop
  }

  
  // MARK: AVCaptureVideoDataOutputSampleBufferDelegate


  /// called when a new image is aviaable from the camera
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)

    let cropRect = CGRect(
        x: crop.origin.x * CGFloat(width),
        y: crop.origin.y * CGFloat(height),
        width: crop.width * CGFloat(width),
        height: crop.height * CGFloat(height)
    )
    
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let cropped = ciImage.cropped(to: cropRect)

    if let cgImage = CIContext().createCGImage(cropped, from: cropped.extent) {
      onNewImage(cgImage)
    }
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
