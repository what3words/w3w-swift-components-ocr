//
//  W3WOcrBaseView.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

import UIKit
import AVFoundation
import W3WSwiftCore

//#if canImport(W3WOcrSdk)


@available(macCatalyst 14.0, *)
public class W3WOcrBasicView: UIView {
  
  // MARK: Vars
  
  /// the camera to show
  var camera: W3WOcrCamera?
  
  /// all the cordinate maths
  var maths: W3WOcrCoordinateMaths!
  
  /// this monitors device orientation
  lazy var orientationObserver = W3WOcrOrientationObserver()
  
  
  public override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  /// Convenience wrapper to get layer as its statically known type.
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }
  
  
  // MARK: Init
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  
  func configure() {
    maths = W3WOcrCoordinateMaths(layer: videoPreviewLayer, camera: camera)

    W3WOcrThread.runOnMain { [weak self] in
      guard let self else { return }
      self.videoPreviewLayer.connection?.videoOrientation = self.orientationObserver.currentOrientationForCamera()
    }
    
    orientationObserver.onNewOrientation = { [weak self, weak orientationObserver] orientation in
      guard let self,
            let orientationObserver
      else {
        return
      }
      
      self.videoPreviewLayer.connection?.videoOrientation = orientation
    }
  }
  
  
  // MARK: Accessors
  
  /// connects the preview layer to the session
  public func set(camera: W3WOcrCamera) {
    self.camera = camera
    
    self.maths = W3WOcrCoordinateMaths(layer: videoPreviewLayer, camera: camera)
    
    if self.videoPreviewLayer.session != camera.session {
      W3WOcrThread.runOnMain { [weak self] in
        guard let self else { return }
        self.configureLayer()
      }
    }
  }
  
  
  func configureLayer() {
    W3WOcrThread.runOnMain { [weak self] in
      guard let self else { return }
      if let session = self.camera?.session {
        self.videoPreviewLayer.session = session
      }
      self.videoPreviewLayer.videoGravity = .resizeAspectFill
      self.videoPreviewLayer.connection?.videoOrientation = self.orientationObserver.currentOrientationForCamera()
      //}
    }
  }
  
  
  /// connects the preview layer to the session
  public func unset(camera: W3WOcrCamera) {
    W3WOcrThread.runOnMain {
      self.videoPreviewLayer.session = nil
    }
    
    self.camera = nil
  }
  
  
  // MARK: UIView overrides
  
  
  /// ensure the orientation is correct when the view changes
  override public func layoutSubviews() {
    videoPreviewLayer.connection?.videoOrientation = orientationObserver.currentOrientationForCamera()
  }
  
}

//#endif // W3WOcrSdk
