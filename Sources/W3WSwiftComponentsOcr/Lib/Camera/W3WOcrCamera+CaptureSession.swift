//
//  W3WOcrCamera+CaptureSession.swift
//  w3w-swift-components-ocr
//
//  Created by Au Nguyen on 09/07/2026.
//

import Foundation
import AVKit

@available(macCatalyst 14.0, *)
extension W3WOcrCamera {

  /// MT-9012 prototype seam: read-only access to the underlying capture session so a host can
  /// attach additional outputs (e.g. an `AVCaptureMetadataOutput` for QR detection) to the SAME
  /// session that feeds the OCR frames, and bind an `AVCaptureVideoPreviewLayer` to it.
  ///
  /// The session only exists after `start()` has run (`connectInputAndOutput` recreates it), so
  /// read this from `onCameraStarted` or later. On the simulator it stays nil (fake frames only).
  ///
  /// Prototype-only: the production design (W3WScannerCore, MT-9012 Rev 2) owns the session and
  /// its outputs internally — this accessor should not outlive the prototype.
  public var captureSession: AVCaptureSession? { session }
}
