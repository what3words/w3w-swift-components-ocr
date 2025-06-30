//
//  W3WVideoStream.swift
//  iosSDK
//
//  Created by what3words on 12/01/2021.
//  Copyright © 2021 what3words. All rights reserved.
//

import Foundation
import CoreImage


#if canImport(W3WOcrSdk)
#else

/// a stream of video, used by autosuggest.  base object for W3WCamera (in the SwiftPM component lib)
open class W3WVideoStream {
  
  /// called when a new image is available
  public var onNewImage: (CGImage) -> () = { _ in }
  
  /// called when there is an error
  public var onError: (W3WOcrError) -> () = { _ in }
  
  /// called when there is inforation about a frame
  public var onFrameInfo: (W3WOcrInfo) -> () = { _ in }
  
  
  /// a stream of video, used by autosuggest.  base object for W3WCamera (in the SwiftPM component lib)
  public init() {
  }
  
  
  /// add an image to the stream.  for example W3WOcrCamera calls this for every image it receives
  /// - Parameters:
  ///     - image: the image to scan
  public func add(image: CGImage) {
    onNewImage(image)
  }
  
  
  /// passes frame info through to the callback closure
  /// - Parameters:
  ///     - info: contains info about the frame, like where there might be text, and if the frame was skipped
  public func feedback(info: W3WOcrInfo) {
    onFrameInfo(info)
  }
  
}

#endif
