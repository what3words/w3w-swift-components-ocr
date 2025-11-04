//
//  W3WOcrOrientationObserver.swift
//  OcrRefactor
//
//  Created by Dave Duprey on 23/06/2021.
//

import Foundation
import AVKit


#if !os(tvOS) && !os(watchOS)

/// class to monitor orientation changes, used in views and camera objects
@available(macCatalyst 14.0, *)
class W3WOcrOrientationObserver {

  /// closure called when device changes orientation
  var onNewOrientation: (AVCaptureVideoOrientation) -> () = { _ in }
  
  /// the current camera orientation
  fileprivate var orientation: AVCaptureVideoOrientation = .portrait
  
  
  /// start monitoring orientation
  init() {
    #if os(macOS)
    orientation = .portrait
    #else
    orientation = currentOrientationForCamera()
    NotificationCenter.default.addObserver(self, selector: #selector(onNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    #endif
  }

  /// remove the view on destruction
  deinit {
    #if !os(macOS)
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    #endif
  }


  #if !os(macOS)

  /// called when the orientatin chages
  @objc fileprivate func onNotification() {
    
    let newOrientation = currentOrientationForCamera()
      
    // only trigger on change
    if orientation != newOrientation {
      orientation = newOrientation
      onNewOrientation(orientation)
    }

  }
  

  /// find AVCaptureVideoOrientation from UIInterfaceOrientation
  func currentOrientationForCamera() -> AVCaptureVideoOrientation {
    
    var newOrientation = UIInterfaceOrientation.portrait
    
    // jump through hoops for different iOS versions
    if #available(iOS 13.0, *) {
      if let o = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
        newOrientation = o
      }
    } else {
      newOrientation = UIApplication.shared.statusBarOrientation
    }
    
    switch (newOrientation) {
    case .portrait:
      return .portrait
    case .landscapeRight:
      return .landscapeRight
    case .landscapeLeft:
      return .landscapeLeft
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }
  
  #else // MacOS
  
  func currentOrientationForCamera() -> AVCaptureVideoOrientation {
    return .portrait
  }
  
  #endif
  
}

#endif
