//
//  File.swift
//  
//
//  Created by Dave Duprey on 23/11/2021.
//

#if canImport(UIKit)
import Foundation
import UIKit
#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk



/// This class conforms to the OCR protocol, but keeps an array
/// of multiple Ocr objects that also conform.  This allows it
/// to select an Ocr system based on priority and which language
/// set it supports.  If the user asked for French, and only one
/// of the provided Ocr systems support that, it will pass calls
/// though to the one that supports French.  If two or more support
/// the requested language, it chooses the first one
public class W3WOcrHybrid: W3WOcrProtocol {
  
  var ocrs = [W3WOcrProtocol]()
  var currentOcrIndex = 0

  
  /// Initialises with multiple Ocr systems
  /// - Parameters:
  ///     - ocrList: an array of objects that conform to the W3WOcrProtocol
  public init(ocrList: [Any]) {
    for ocr in ocrList {
      if let o = ocr as? W3WOcrProtocol {
        ocrs.append(o)
      }
      #if canImport(W3WOcrSdk)
      if let o = ocr as? W3WOcr {
        ocrs.append(W3WOcrSdkWrapper(ocr: o))
      }
      #endif
    }
          
  }
  
  
  /// Sets the language to use for scanning.  It will choose from
  /// among the provided OCR systems and use the first one that
  /// supports the language in question
  /// - Parameters:
  ///     - language: a two letter ISO code for the language to use
  public func set(language: String) throws {

    // loop through available OCR systems in order
    for i in 0..<ocrs.count {
      let languages = ocrs[i].availableLanguages()
      
      // if an exact match of the requested langauge is found, set this ocr as current and set the language
      if languages.contains(language) {
        try ocrs[i].set(language: language)
        currentOcrIndex = i
        return
      
      // if there is a match for the the language group, but maybe not the dialect
      } else if let lang = languages.first(where: { l in l.prefix(2) == language }) {
        try ocrs[i].set(language: lang)
        currentOcrIndex = i
        return

      }
    }

    // user asked for unsupported langage
    throw W3WOcrError.coreError(message: "Langauge not supported")
  }


  /// Returns a list of languages which is the union of the languages
  /// supported by all the Ocr systems available
  /// - Returns: A string array of two letter ISO langauge codes
  public func availableLanguages() -> [String] {
    var languages = [String]()
    
    for ocr in ocrs {
      let list = ocr.availableLanguages()
      for language in list {
        let l = language.prefix(2)
        if !languages.contains(String(l)) {
          languages.append(String(l))
        }
      }
    }
    
    return languages
  }
  
  
  /// scans an image for three word address
  /// - Parameters:
  ///     - image: the image to scan
  ///     - info: (optional) called with information about the image passed in
  ///     - completion: called when a three word address is found
  public func autosuggest(image: CGImage, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    ocrs[currentOcrIndex].autosuggest(image: image, info: info, completion: completion)
  }
  
  
  /// scans a videostream for three word addresses
  /// - Parameters:
  ///     - image: the image to scan
  ///     - completion: called when a three word address is found
  public func autosuggest(video: W3WVideoStream, completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    ocrs[currentOcrIndex].autosuggest(video: video, completion: completion)
  }
  
  
  /// tell OCR to stop processing, this operating is threaded and takes time
  /// - Parameters:
  ///     - completion: called when all the OCR threads have been finally stopped
  public func stop(completion: @escaping () -> ()) {
    ocrs[currentOcrIndex].stop(completion: completion)
  }
  
  
  
}
#endif
