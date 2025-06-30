//
//  File.swift
//
//
//  Created by Dave Duprey on 19/10/2021.
//

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk

import Foundation
import CoreImage
import W3WSwiftCore


public protocol W3WOcrProtocol {


  /// sets the language to use
  /// - Parameters:
  ///     - language: an ISO 639-1 2 letter language code
  func set(language: String) throws

  
  /// returns an array of  ISO 639-1 2 letter language codes indicating which langauges are supported
  func availableLanguages() -> [String]

  
  /// scans an image for three word address
  /// - Parameters:
  ///     - image: the image to scan
  ///     - info: (optional) called with information about the image passed in
  ///     - completion: called when a three word address is found
  func autosuggest(image: CGImage, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ())


  /// scans a videostream for three word addresses
  /// - Parameters:
  ///     - image: the image to scan
  ///     - completion: called when a three word address is found
  func autosuggest(video: W3WVideoStream, completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ())


  /// tell OCR to stop processing, this operating is threaded and takes time
  /// - Parameters:
  ///     - completion: called when all the OCR threads have been finally stopped
  func stop(completion: @escaping () -> ())


}
