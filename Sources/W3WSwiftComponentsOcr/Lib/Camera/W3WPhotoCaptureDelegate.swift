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
            
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData)?.orientationFixed,
              let cgImage = uiImage.cgImage else {
            print("Could not create UIImage from data.")
            completionHandler(nil)
            return
        }
        
        completionHandler(cgImage)
    }
}

private extension UIImage {
    var orientationFixed: UIImage {
        guard imageOrientation != .up, let cgImage, let colorSpace = cgImage.colorSpace else { return self }
        
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            
        case .up, .upMirrored:
            break
            
        @unknown default:
            break
        }
                
        if let ctx = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            ctx.concatenate(transform)
            
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }
        return self
    }
}
