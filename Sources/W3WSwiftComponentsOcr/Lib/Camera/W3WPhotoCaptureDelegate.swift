//
//  W3WPhotoCaptureDelegate.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 08/07/2025.
//

import AVKit


// This class will act as the delegate for AVCapturePhotoOutput
// It needs to be an NSObject to conform to AVCapturePhotoCaptureDelegate
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
  var crop: CGRect?
  
  var completionHandler: ((CGImage?) -> Void)?
    
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      print("Error capturing photo: \(error.localizedDescription)")
      completionHandler?(nil)
      return
    }

    guard let cgImage = photo.cgImageRepresentation() else {
      completionHandler?(nil)
      return
    }
    
    guard let crop else {
      completionHandler?(cgImage.oriented(photo.metadata))
      return
    }
    
    let cropRect = CGRect(
      x: crop.origin.x * CGFloat(cgImage.width),
      y: crop.origin.y * CGFloat(cgImage.height),
      width: crop.width * CGFloat(cgImage.width),
      height: crop.height * CGFloat(cgImage.height)
    )
    guard let croppedImage = cgImage.cropping(to: cropRect) else {
      completionHandler?(cgImage.oriented(photo.metadata))
      return
    }
    
    completionHandler?(croppedImage.oriented(photo.metadata))
  }
}

private extension CGImage {
  /**
   Returns a new `CGImage` with the correct orientation applied
   based on the provided EXIF metadata.
   
   - Important:
   `AVCapturePhoto.cgImageRepresentation()` always returns the raw image
   from the sensor in its default orientation (usually landscape),
   and **does not** apply the orientation automatically.
   The actual orientation is stored in `photo.metadata[kCGImagePropertyOrientation]`.
   
   - Parameter metadata: A metadata dictionary from `AVCapturePhoto.metadata`
   containing the `kCGImagePropertyOrientation` key.
   
   - Returns: A new `CGImage` with the correct orientation applied,
   or `nil` if the transformation fails.
   */
  func oriented(_ metadata: [String : Any]) -> CGImage? {
    let orientationRaw = metadata[kCGImagePropertyOrientation as String] as? UInt32 ?? 1
    let exifOrientation = CGImagePropertyOrientation(rawValue: orientationRaw) ?? .up
    
    let ciImage = CIImage(cgImage: self).oriented(exifOrientation)
    let context = CIContext(options: nil)
    return context.createCGImage(ciImage, from: ciImage.extent)
  }
}
