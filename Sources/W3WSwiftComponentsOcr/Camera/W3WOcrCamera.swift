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
  
  // MARK: Vars
  
  /// iOS audio visual system handle
  var session: AVCaptureSession?
  
  /// reference to the active camera
  var camera: AVCaptureDevice?
  
  /// video input tap
  var input: AVCaptureDeviceInput?
  
  /// video output tap
  var output: AVCaptureVideoDataOutput?
  
  /// thread to be used to process IO
  var thread = DispatchQueue.global(qos: .default)
  
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
    
    connectInputAndOutput()
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
    
    //connectInputAndOutput()
  }
  
  
  // MARK: Start / Stop
  
  
  /// tell the camera to start producing images
  public func start() {
    //print("camera.start()")
    connectInputAndOutput()
    
    // if this is the simulator, then fake the real camera
#if targetEnvironment(simulator)
    imageProcessor.start()
#else
    thread.async {
      print(#function, "async ", "START")
      self.session?.beginConfiguration()
      self.session?.commitConfiguration()
      self.session?.startRunning()
      print(#function, "async ", "STOP")
    }
#endif
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      guard let self else { return }
      self.onCameraStarted?()
    }
  }
  
  
  /// tell the camera to stop producing images
  public func stop() {
    //print("camera.stop()")
    // if this is the simulator, then fake the real camera
#if targetEnvironment(simulator)
    imageProcessor.stop()
    disconnectInputAndOutput()
#else
    thread.async {
      self.session?.stopRunning()
      self.disconnectInputAndOutput()
    }
#endif
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
    imageProcessor.set(crop: CGRect(x: trunc(crop.origin.x), y: trunc(crop.origin.y), width: trunc(crop.size.width), height: trunc(crop.size.height)))
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
    } else {
      if let r = inputDimensions() {
        resolution = r
      }
    }
    
    return resolution
  }
  
  
  /// Returns the resolution of the active input device
  /// - Returns: the resolution of the active input device
  public func inputDimensions() -> CGSize? {
    // get the video dimensions
    if let formatDescription = input?.device.activeFormat.formatDescription {
      let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
      if imageProcessor.orientation == .portrait || imageProcessor.orientation == .portraitUpsideDown {
        return CGSize(width: CGFloat(videoDimensions.height), height: CGFloat(videoDimensions.width))
      } else {
        return CGSize(width: CGFloat(videoDimensions.width), height: CGFloat(videoDimensions.height))
      }
    }
    
    return nil
  }
  
  
  // MARK: AV System Stuff
  
  
  /// connects the camera and output to the session
  /// designed to allow being called multiple times
  /// if called more than once, it will not do anything the second time
  func connectInputAndOutput() {
    startAvSystem()
    
    // assign the delegates callback for camera images
    imageProcessor.onNewImage = { [weak self] image in
      self?.onNewImage(image)
    }
    
    // connect the camera IO to the delegate
    if let session = session {
      if session.inputs.count == 0 {
        //session.sessionPreset = preset
        
        if let c = camera {
          if let i = try? AVCaptureDeviceInput(device: c) {
            print(#function, "START")
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
            print(#function, "STARTED")
          }
        }
      }
    }
  }
  
  
  /// disconnects the camera and output to the session
  func disconnectInputAndOutput() {
    DispatchQueue.global().async {
      //print(#function, "START")
      for input in self.session?.inputs ?? [] {
        self.session?.removeInput(input)
      }
      
      for output in self.session?.outputs ?? [] {
        self.session?.removeOutput(output)
      }
      //print(#function, "STOP")
    }
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

