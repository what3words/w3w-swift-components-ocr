//
//  W3WOcrCamera.swift
//  CameraDevelopment
//
//  Created by Dave Duprey on 09/02/2021.
//

import Foundation
import AVKit
import CoreGraphics
import W3WSwiftCore

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk


/// Interface for iOS' camera for the OCR SDK
@available(macCatalyst 14.0, *)
public class W3WOcrCamera: W3WVideoStream {
  let id = UUID()
  
  // MARK: Vars
  
  /// iOS audio visual system handle
  var session: AVCaptureSession?
  
  /// reference to the active camera
  var camera: AVCaptureDevice?
  
  /// video input tap
  var input: AVCaptureDeviceInput?
  
  /// video output tap
  var output: AVCaptureVideoDataOutput?
  
  /// photo output tap (for still images)
  var photoOutput: AVCapturePhotoOutput?
  
  /// A temporary delegate for photo capture to get a still image
  private let photoCaptureDelegate = PhotoCaptureProcessor()

  /// thread to be used to process IO
  private let thread = DispatchQueue(label: "background_queue", qos: .userInitiated, target: .global())
  
  /// delegate to capture the camera output
  let imageProcessor: W3WCameraImageProcessor! //() // AVCaptureVideoDataOutputSampleBufferDelegate needs to be a NSObject derivitive.  This class isn't, so we make a member object that conforms
  
  /// called when Camera has started
  public var onCameraStarted: (() -> ())?
  
  // MARK: Init
  
  
  /// initialise a camera given it's iOS handle, and orientation
  /// - Parameters:
  ///     - camera: the camera to use
  ///     - orientation: the orientation of the camera
  public init(camera: AVCaptureDevice?) {
    // assign the camera and orientation locally
    self.camera = camera
    
    // make a delegate to hanfle the incoming images
    imageProcessor = W3WCameraImageProcessor()
    
    // init the W3WOcrVideoStream parent class
    super.init()
  }
  
  
  /// initialise a camera without the AVDevice, generally for use with the iOS simullator
  /// - Parameters:
  ///     - camera: the camera to use
  ///     - orientation: the orientation of the camera
  override public init() {
    // make a delegate to hanfle the incoming images
    imageProcessor = W3WCameraImageProcessor()
    
    // init the W3WOcrVideoStream parent class
    super.init()
  }
  
  
  // MARK: Start / Stop
  
  
  /// tell the camera to start producing images
  public func start() {
    connectInputAndOutput()
    
    // if this is the simulator, then fake the real camera
#if targetEnvironment(simulator)
    imageProcessor.start()
#else
    thread.sync { [weak self] in
      self?.session?.startRunning()
    }
#endif
    startCountdown()
  }
  
  private func startCountdown() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      guard let self else { return }
      self.onCameraStarted?()
    }
  }
  
  
  /// keep camera connected to view, but stop running
  public func pause() {
    if self.session?.isRunning ?? false {
      self.session?.stopRunning()
    }
  }
  
  
  /// start paused camera back up again
  public func unpause() {
    if !(self.session?.isRunning ?? false) {
      W3WThread.runInBackground { [weak self] in
        self?.session?.startRunning()
      }
    }
  }

  
  /// tell the camera to stop producing images
  public func stop() {
    //print("camera.stop()")
    // if this is the simulator, then fake the real camera
#if targetEnvironment(simulator)
    imageProcessor.stop()
#else
    
    thread.sync { [weak self] in
      guard let self else { return }
      self.session?.stopRunning()
      self.session = nil
    }
#endif
    
    W3WOcrCamera.cameraList?.removeAll()
    W3WOcrCamera.cameraList = nil
  }
  
  
  public func startAvSystem() {
    if session == nil {
      session = AVCaptureSession()
    }
  }
  
  
  // MARK: Accessors
  
  
  /// sets a crop for all returning images in camera coordinates
  /// - Parameters:
  ///     - crop: the region to crop images to, provided in camera coordinates
  public func set(crop: CGRect) {
    imageProcessor.set(crop: crop)
    photoCaptureDelegate.crop = crop
  }
  
  
  /// returns the current camera crop value
  public func getCrop() -> CGRect? {
    return imageProcessor?.crop
  }
  
  
  
  /// returns the current camera resolution, may change after the camera starts up, as the `preset:AVCaptureSession.Preset`
  /// is more of a suggestion, and depends on actual hardware
  /// - Returns: Camera resolution
  public func getResolution() -> CGSize? {
    var resolution: CGSize?
    
    if let r = imageProcessor.resolution {
      resolution = r
    }
    
    return resolution
  }
  
  
  // MARK: AV System Stuff
  
  
  /// connects the camera and output to the session
  /// designed to allow being called multiple times
  /// if called more than once, it will not do anything the second time
  func connectInputAndOutput() {
    //print(#function, "START")
    self.session = nil
    startAvSystem()
    session?.beginConfiguration()
    // assign the delegates callback for camera images
    imageProcessor.onNewImage = { [weak self] image in
      guard let self else { return }
      self.onNewImage(image)
    }
    
    // connect the camera IO to the delegate
    if let session {
      if session.canSetSessionPreset(.photo) {
        session.sessionPreset = .photo
        print("W3WOcrCamera Debug: Session preset set to .photo")
      } else {
        print("W3WOcrCamera Warning: Cannot set session preset to .photo. Falling back to default.")
      }
      
      if let c = camera {
        if let i = try? AVCaptureDeviceInput(device: c) {
          input  = i
          output = AVCaptureVideoDataOutput()
          
          if let cameraOutput = output {
            if session.canAddInput(i) && session.canAddOutput(cameraOutput) {
              session.addInput(i)
              session.addOutput(cameraOutput)
            }
          }
          
          // set the delegate and thread to use for camera output
          output?.setSampleBufferDelegate(imageProcessor, queue: thread)

          // Setup AVCapturePhotoOutput for still images
          photoOutput = AVCapturePhotoOutput()
          if let photoOutput = photoOutput {
            photoOutput.isHighResolutionCaptureEnabled = true
            if session.canAddOutput(photoOutput) {
              session.addOutput(photoOutput)
            }
          }
        }
      }
    }
    session?.commitConfiguration()
  }
  
  
  // MARK: - Capture Still Image
   
   /// Captures a still image and returns it as a CGImage.
   /// - Parameter completion: A closure that will be called with the captured CGImage or nil if an error occurs.
  public func captureStillImage(completion: @escaping (CGImage?) -> Void) {
      #if targetEnvironment(simulator)
        let faker = W3WOcrFakeImages()
        let image = faker.makeRandomThreeWordAddressImage(rect: CGRect(origin: .zero, size: CGSize(width: 1024.0, height: 768.0)))
        completion(image)
        return
      #endif

      guard let photoOutput = photoOutput else {
          completion(nil)
          return
      }
          
      // Use a photo settings for high-resolution output
      let photoSettings = AVCapturePhotoSettings()
       
      // Ensure high resolution is enabled for this specific photo capture request.
      if photoOutput.isHighResolutionCaptureEnabled {
          photoSettings.isHighResolutionPhotoEnabled = true
          print("W3WOcrCamera Debug: High resolution photo enabled for capture settings.")
      } else {
          print("W3WocrCamera Warning: High resolution capture is NOT enabled for photoOutput itself.")
      }
        
      // Create a temporary delegate for this capture
    
      photoCaptureDelegate.completionHandler = { [weak self] cgImage in
        self?.photoCaptureDelegate.completionHandler = nil
        completion(cgImage)
      }
    
      // Capture the photo
      photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
  }
  
  
  // MARK: - Camera Access - Static
  
  
  /// conatins a list of currently available cameras
  private static var cameraList: [W3WVideoStream]?
  
  
  /// ask user for camera permission
  /// - Parameters:
  ///     - completion: closure called with success result
  static func requestPermissionFromUser(completion: @escaping (Bool) -> ()) {
    DispatchQueue.main.async {
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    }
  }
  
  
  /// gets permission to use the camera from the user
  /// - Parameters:
  ///     - completion: a completion block carrying a boolean indicating success or failure
  public static func getCameraPermission(completion: @escaping (Bool) -> () ) {
    DispatchQueue.main.async {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
        
        // The user has previously granted access to the camera.
      case .authorized:
        completion(true)
        
        // The user has not yet been asked for camera access.
      case .notDetermined:
        W3WOcrCamera.requestPermissionFromUser(completion: completion)
        
        // The user has previously denied access.
      case .denied:
        completion(false)
        
        // The user can't grant access due to restrictions.
      case .restricted:
        completion(false)
        
        // unknown future state
      @unknown default:
        W3WOcrCamera.requestPermissionFromUser(completion: completion)
      }
    }
  }
  
  
  
  /// gets a list of available cameras for a paticular orientation
  /// - Parameters:
  ///     - orientation: the orientation of the device
  public static func list() -> [W3WVideoStream] {
    findAvailableCameras()
    
    return cameraList ?? [W3WVideoStream]()
  }
  
  
  /// get an instance of W3WOcrCamera for the desired position and orientation
  /// - Parameters:
  ///     - position: the camera to use, eg: .front, .back
  ///     - orientation: the orientation of the device
  static public func get(camera position: AVCaptureDevice.Position) -> W3WOcrCamera? {
    var camera: W3WOcrCamera?
    
    let list = W3WOcrCamera.list()
    
    // return the first matching camera - they are in order of the best to worst for the job
    for cam in list {
      if let c = cam as? W3WOcrCamera {
        if c.camera?.position == position {
          return c
        }
      }
    }
    
    // If this is compiled for simulator, then make a fake camera
#if targetEnvironment(simulator)
    if cameraList?.count == 0 {
      camera = W3WOcrCamera()
      cameraList?.append(camera!)
    } else {
      camera = cameraList?.first as? W3WOcrCamera
    }
#endif
    
    return camera
  }
  
  
  /// fill `cameraList` with the avialable cameras
  /// - Parameters:
  ///     - orientation: the orientation of the device
  static func findAvailableCameras() {
    
    // if we've not queried the cameras before
    if cameraList == nil {
      // make an empty list of cameras
      cameraList = [W3WOcrCamera]()
      
      if #available(iOS 10.0, *) {
        var deviceTypes = [AVCaptureDevice.DeviceType]()
        
        // iOS 13 brings tripple and dual wide cameras
        if #available(iOS 13.0, *) {
          deviceTypes.append(.builtInTripleCamera)
          deviceTypes.append(.builtInDualWideCamera)
        }
        
        // iOS 10.2 required for Dual Camera
        if #available(iOS 10.2, *) {
          deviceTypes.append(.builtInDualCamera)
        }
       
        deviceTypes.append(.builtInWideAngleCamera)
        
        let discorverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
        for device in discorverySession.devices {
          cameraList?.append(W3WOcrCamera(camera: device))
        }
      }
    }
  }
  
}

