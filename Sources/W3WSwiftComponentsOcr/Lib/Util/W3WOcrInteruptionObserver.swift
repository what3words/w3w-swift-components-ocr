//
//  File.swift
//
//
//  Created by Dave Duprey on 06/07/2021.
//

import Foundation

//#if canImport(W3WOcrSdk)


@available(macCatalyst 14.0, *)
class W3WOcrInteruptionObserver {

  public var onInteruption: () -> () = { }

  
  // MARK: Observers


  func startListeningForInteruptions(camera: W3WOcrCamera?) {
    if let c = camera {
      NotificationCenter.default.addObserver(self, selector: #selector(sessionInterupted), name: .AVCaptureSessionWasInterrupted, object: c.session)
    }
  }


  func stopListeningForInteruptions(camera: W3WOcrCamera?) {
    if let c = camera {
      NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: c.session)
    }
  }


  @objc func sessionInterupted() {
    onInteruption()
  }
 

}

//#endif // W3WOcrSdk
