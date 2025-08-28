//
//  W3WSuOcrView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import AVFoundation


struct W3WSuOcrView: UIViewRepresentable {
  let session: AVCaptureSession?
  
  func makeUIView(context: Context) -> UIView {
    PreviewView(session: session)
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}


private extension W3WSuOcrView {
  final class PreviewView: UIView {
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    convenience init(session: AVCaptureSession?) {
      self.init(frame: .zero)
      previewLayer.videoGravity = .resizeAspectFill
      layer.addSublayer(previewLayer)
      
      previewLayer.session = session
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      previewLayer.frame = bounds
    }
  }
}
