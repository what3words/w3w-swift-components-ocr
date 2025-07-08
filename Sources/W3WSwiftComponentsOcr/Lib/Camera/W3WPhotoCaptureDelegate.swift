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
    private var completionHandler: ((CGImage?) -> Void)
    
    init(completion: @escaping (CGImage?) -> Void) {
        self.completionHandler = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        guard let pixelBuffer = photo.pixelBuffer else {
            print("Could not get pixel buffer from photo.")
            completionHandler(nil)
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            completionHandler(cgImage)
        } else {
            print("Could not create CGImage from CIImage.")
            completionHandler(nil)
        }
    }
}
