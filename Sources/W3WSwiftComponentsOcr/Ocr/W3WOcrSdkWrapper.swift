////
////  File.swift
////
////
////  Created by Dave Duprey on 19/10/2021.
////
//
//
#if canImport(W3WOcrSdk)
import W3WOcrSdk
import Foundation
import W3WSwiftCore


public class W3WOcrSdkWrapper: W3WOcrProtocol {
  
  
  public func availableLanguages() -> [String] {
    return ["de", "en", "es", "pt", "ro", "ru"]
  }
  
  
  var ocr: W3WOcr!
  
  public init(ocr: W3WOcr) {
    self.ocr = ocr
  }
 
  
  public func set(language: String) throws {
    try ocr.set(language: language)
  }
  
  
  public func autosuggest(image: CGImage, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    ocr.autosuggest(image: image, info: info, completion: completion)
  }
  
  public func autosuggest(video: W3WVideoStream, completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    ocr.autosuggest(video: video, completion: { suggestions in completion(suggestions, nil) })
  }
  
  public func stop(completion: @escaping () -> ()) {
    ocr.stop {
      completion()
    }
  }
  
  
}


#endif
