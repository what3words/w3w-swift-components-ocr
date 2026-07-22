//
//  W3WOcrCamera.swift
//  CameraDevelopment
//
//  Created by Dave Duprey on 09/02/2021.
//

import Foundation
import AVKit
import CoreGraphics
import W3WSwiftScanner

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


/// Interface for iOS' camera for the OCR SDK — a `W3WVideoStream` façade over the unified
/// `W3WScannerCamera` in w3w-swift-scanner
@available(macCatalyst 14.0, *)
public class W3WOcrCamera: W3WVideoStream {

  // MARK: Vars

  /// the unified capture camera (w3w-swift-scanner); this facade adapts its outputs
  let core: W3WScannerCamera

  /// stable identity of the underlying camera — views key their session refresh off this
  var id: UUID { core.id }

  /// the underlying capture session, for binding a preview layer to the SAME session that
  /// feeds the OCR frames; only exists after `start()` has run (nil on the simulator)
  var session: AVCaptureSession? { core.captureSession }

  /// read-only access to the capture session for hosts (e.g. preview layers)
  public var captureSession: AVCaptureSession? { core.captureSession }

#if targetEnvironment(simulator)
  /// one faker reused across the ~10fps simulated frames
  private let fakeImages = W3WOcrFakeImages()
#endif

  /// called when Camera has started
  public var onCameraStarted: (() -> ())? {
    get { core.onCameraStarted }
    set { core.onCameraStarted = newValue }
  }

  /// called when a QR code is detected in the camera feed
  /// setting this before `start()` attaches an `AVCaptureMetadataOutput` for QR
  /// to the capture session; leaving it nil keeps the session untouched.
  /// detection runs in the system capture pipeline, callbacks only fire on a hit
  /// (repeated sightings of the same code are suppressed while it stays in frame)
  public var onQRCode: ((String) -> ())? {
    get { core.onQRCode }
    set { core.onQRCode = newValue }
  }

  /// consulted per sighting while QR detection is attached; return false to drop
  /// hits without delivering them (e.g. only detect while in live scan mode).
  /// dropped sightings don't slide the duplicate-suppression window, so flipping
  /// back to true delivers a code still in frame immediately
  public var qrDetectionActive: () -> Bool {
    get { core.qrDetectionActive }
    set { core.qrDetectionActive = newValue }
  }

  // MARK: Init


  /// wrap the unified scanner camera, bridging its frame output into this
  /// `W3WVideoStream` (which the OCR engine taps via `onNewImage`)
  init(core: W3WScannerCamera) {
    self.core = core
    super.init()

    core.onNewImage = { [weak self] image in
      self?.onNewImage(image)
    }

#if targetEnvironment(simulator)
    // the scanner camera fakes frames on the simulator; OCR supplies the content
    core.simulatorFakeImage = { [fakeImages] rect in
      fakeImages.makeRandomThreeWordAddressImage(rect: rect)
    }
#endif
  }


  // MARK: Start / Stop


  /// tell the camera to start producing images
  public func start(completion: @escaping () -> Void = {}) {
    core.start(completion: completion)
  }


  /// keep camera connected to view, but stop running
  public func pause() {
    core.pause()
  }


  /// start paused camera back up again
  public func unpause() {
    core.unpause()
  }


  /// tell the camera to stop producing images
  public func stop() {
    core.stop()
  }


  // MARK: Accessors


  /// sets a crop for all returning images in camera coordinates
  /// - Parameters:
  ///     - crop: the region to crop images to, provided in camera coordinates
  public func set(crop: CGRect) {
    core.set(crop: crop)
  }


  /// returns the current camera crop value
  public func getCrop() -> CGRect? {
    return core.getCrop()
  }


  /// returns the current camera resolution, may change after the camera starts up
  /// - Returns: Camera resolution
  public func getResolution() -> CGSize? {
    return core.getResolution()
  }


  // MARK: - Capture Still Image

  /// Captures a still image and returns it as a CGImage.
  /// (On the simulator the scanner camera serves the injected fake image.)
  /// - Parameter completion: A closure that will be called with the captured CGImage or nil if an error occurs.
  public func captureStillImage(completion: @escaping (CGImage?) -> Void) {
    core.captureStillImage(completion: completion)
  }


  // MARK: - Camera Access - Static


  /// gets permission to use the camera from the user
  /// - Parameters:
  ///     - completion: a completion block carrying a boolean indicating success or failure
  public static func getCameraPermission(completion: @escaping (Bool) -> () ) {
    W3WScannerCamera.getCameraPermission(completion: completion)
  }


  /// get an instance of W3WOcrCamera for the desired position
  /// - Parameters:
  ///     - position: the camera to use, eg: .front, .back
  static public func get(camera position: AVCaptureDevice.Position) -> W3WOcrCamera? {
    guard let core = W3WScannerCamera.get(camera: position) else { return nil }
    return W3WOcrCamera(core: core)
  }

}
