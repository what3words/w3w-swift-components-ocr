//
//  W3WSuOcrView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import AVFoundation
import Combine

struct W3WSuOcrView: UIViewRepresentable {
  let session: AVCaptureSession?
  let cropRect: CGRect
  let previewCropHandler: (CGRect) -> Void
  
  func makeUIView(context: Context) -> UIView {
    PreviewView(session: session, cropRect: cropRect, previewCropHandler: previewCropHandler)
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}


private extension W3WSuOcrView {
  final class PreviewView: UIView {
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var cancellables: Set<AnyCancellable> = []
    
    convenience init(
      session: AVCaptureSession?,
      cropRect: CGRect,
      previewCropHandler: @escaping (CGRect) -> Void
    ) {
      self.init(frame: .zero)
      previewLayer.videoGravity = .resizeAspectFill
      layer.addSublayer(previewLayer)
      previewLayer.session = session
      
      // Observe when the preview layer is actually rendering (`isPreviewing == true`)
      // and when it has a valid layout (`bounds != .zero`).
      // Once both conditions are met, wait 1 second to ensure the capture session
      // has rendered at least one frame on the preview layer, then convert the
      // given cropRect from layer coordinates into a normalized metadata rect
      // (0–1 in the capture coordinate space) and forward it through
      // `previewCropHandler`. This ensures the crop area is calculated only after
      // the preview is ready and displaying frames correctly.
      let isPreviewing = previewLayer.publisher(for: \.isPreviewing).filter { $0 }
      let didLayout = previewLayer.publisher(for: \.bounds).filter { $0 != .zero }
      Publishers.CombineLatest(isPreviewing, didLayout)
        .delay(for: .seconds(1), scheduler: RunLoop.main)
        .sink(receiveValue: { [weak self] frame in
          guard let self else { return }
          let normalized = previewLayer.metadataOutputRectConverted(fromLayerRect: cropRect)
          previewCropHandler(normalized)
        })
        .store(in: &cancellables)
    }
        
    override func layoutSubviews() {
      super.layoutSubviews()
      previewLayer.frame = bounds
      previewLayer.connection?.videoOrientation = UIDevice.current.videoOrientation
    }
  }
}

private extension UIDevice {
  var videoOrientation: AVCaptureVideoOrientation {
    switch orientation {
    case .portrait: .portrait
    case .portraitUpsideDown: .portraitUpsideDown
    case .landscapeLeft: .landscapeRight
    case .landscapeRight: .landscapeLeft
    default: .portrait
    }
  }
}
