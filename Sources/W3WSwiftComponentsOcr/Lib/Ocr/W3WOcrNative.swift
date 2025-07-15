//
//  File.swift
//
//
//  Created by Dave Duprey on 29/09/2021.
//

import Foundation
import Vision
import CoreLocation
import W3WSwiftCore
#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk

#if canImport(w3w)
import w3w
extension What3Words: W3WUtilitiesProtocol { }
#endif // w3w



@available(iOS 13.0, *)
public class W3WOcrNative: W3WOcrProtocol {

  /// languages to use for recognition
  var languages = ["en"]  // LiveType supports at least English, so this is hardcoded
  
  /// lastImageResolution
  var lastImageResolution = CGSize(width: 1.0, height: 1.0)

  /// the languages this supports
  var supportedLanguages = [String]()
  
  /// Create a new request to recognize text.
  var request: VNRecognizeTextRequest?

  /// what3words api/sdk
  var w3w: W3WProtocolV4!
  
  /// called when a new image frame is available from the camera
  var info: (W3WOcrInfo) -> () = { _ in }

  /// called when something has been found
  var completion: ([W3WOcrSuggestion], W3WOcrError?) -> () = { _,_ in }
  
  /// focus for calculating distance to focus
  var focus: CLLocationCoordinate2D?

  /// This caches valid three word addresses to validate them in order
  /// to prevent multiple calls to the API for the same text.
  /// There are rules in the API licence agreement surrounding the issue
  /// of storing, pre-fetching, caching, indexing, copying, or re-utilising
  /// what3words data.  However, item 6.3(e) (2021 agreement) permits the
  /// storage an unlimited number of 3 Word Addresses without their
  /// corresponding coordinates.  This caching object does not store
  /// coordinates
  static var suggestionCache = [String : (Bool, W3WOcrSuggestion?)]()
  
  /// flag to indicate if there is a convert to coordinates call happening,
  /// in which case we stop sending queries until it's done.  note this
  /// doesn't need to be a semaphore or atomic in any way as it's okay
  /// to make more than one call at a time, but in general we'd like to
  /// slow the calls to the API down to a reasonable rate
  static var callingC2C = false
  

  /// Creates an OCR class based on VNRecognizeTextRequest - CoreML's
  /// OCR system provided by Apple
  /// - Parameters:
  ///   - w3w: A refernce to the what3words API or the SDK
  public init(_ w3w: W3WProtocolV4) {
    configure(w3w: w3w)
  }
  
  
#if canImport(w3w)
  public init(sdk: What3Words) {
    configure(w3w: sdk as! W3WProtocolV4)
  }
#endif // w3w

  
  func configure(w3w: W3WProtocolV4) {
    self.w3w = w3w
    
    // get a list of langauges from the system
    let temp = VNRecognizeTextRequest(completionHandler: { _, _ in })
    if #available(iOS 15.0, *) {
      if let ocrLangauges = try? temp.supportedRecognitionLanguages() { //}, let w3wLanguages = languages {
        self.supportedLanguages = ocrLangauges
        //self.languagesQueried = true
      }
    }
    
    // temper that list by removing any languages w3w doesn't support
    self.w3w.availableLanguages() { languages, error in
      if let w3wLanguages = languages {
        self.supportedLanguages = self.w3wSupported(ocrLangauges: self.supportedLanguages, w3wLangauges: w3wLanguages)
      }
    }
  }
  
  
  /// returns the union of the two lists
  func w3wSupported(ocrLangauges: [String], w3wLangauges: [W3WLanguage]) -> [String] {
    var supported = [String]()
    
    for code in ocrLangauges {
      if w3wSupported(code: code, langauges: w3wLangauges) {
        supported.append(code)
      }
    }
    
    return supported
  }
  
  
  /// checks if a language is in a language array
  func w3wSupported(code: String, langauges: [W3WLanguage]) -> Bool {
    for langauge in langauges {
      if code.prefix(2) == langauge.code {
        return true
      }
    }
    
    return false
  }
  
  
  deinit {
  }
  
  
  /// Sets the language to use for scanning.
  /// - Parameters:
  ///     - language: a two letter ISO code for the language to use
  public func set(language: String) throws {
    self.languages = [language]
  }
  
  
  /// Sets the languages to use for scanning.
  /// - Parameters:
  ///     - language: an array of two letter ISO code for the language to use
  func set(languages: [String]) throws {
    self.languages = languages
  }
  
  
  public func set(focus: CLLocationCoordinate2D?) {
    self.focus = focus
  }
  

  /// returns an array of  ISO 639-1 2 letter language codes indicating which langauges are supported
  public func availableLanguages() -> [String] {
    return supportedLanguages
  }
  
  
  /// scans an image for three word address
  /// - Parameters:
  ///     - image: the image to scan
  ///     - info: (optional) called with information about the image passed in
  ///     - completion: called when a three word address is found
  public func autosuggest(image: CGImage, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ())  {
    //W3WOcrNative.callingC2C = false
    
    // Create a new request to recognize text if not there already
    if request == nil {
      request = VNRecognizeTextRequest(completionHandler: { [weak self] request, error in self?.recognizeTextHandler(request: request, error: error, info: info, completion: completion)})
    }
    request?.recognitionLanguages = languages
    
    // Create a new image-request handler.
    if let r = request {
      let requestHandler = VNImageRequestHandler(cgImage: image)
      try? requestHandler.perform([r])
    }
  }
  
  
  /// scans a videostream for three word addresses
  /// - Parameters:
  ///     - image: the image to scan
  ///     - info: (optional) called with information about the image passed in
  ///     - completion: called when a three word address is found
  public func autosuggest(video: W3WVideoStream, completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ())  {
    self.completion = completion
    self.info       = { info in video.onFrameInfo(info) }
    
    video.onNewImage = { [weak self, weak video] image in
      guard let self,
            let video
      else {
        return
      }
      self.lastImageResolution = CGSize(width: image.width, height: image.height)
      self.autosuggest(image: image, info: self.info, completion: { suggestions, error in self.completion(suggestions, error) })
    }
  }
  
  
  /// tell OCR to stop processing, this operating is threaded and takes time
  /// - Parameters:
  ///     - completion: called when all the OCR threads have been finally stopped
  public func stop(completion: @escaping () -> () = { }) {
    W3WOcrNative.callingC2C = false
    request = nil
    completion()
  }

  
#if canImport(w3w)

  
  /// If we have the SDK we can make calls faster, so we use a different algorythm than if only the API is available
  func recognizeTextHandler(request: VNRequest, error: Error?, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    if let sdk = w3w as? What3Words {
      recognizeTextHandlerSdk(sdk: sdk, request: request, error: error, info: info, completion: completion)
    } else {
      recognizeTextHandlerApi(request: request, error: error, info: info, completion: completion)
    }
  }
  
  
  /// This does the work of recognising the text, optimised for using the SDK
  func recognizeTextHandlerSdk(sdk: What3Words, request: VNRequest, error: Error?, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    if let observations = request.results as? [VNRecognizedTextObservation] {
      
      var suggestions = [W3WOcrSuggestion]()
      
      // prepare info on the values returned
      let frameInfo = W3WOcrInfo()
      frameInfo.droppedFrame = false
      frameInfo.boxes = [W3WOcrRect]()
      
      var fullText = ""
      
      // loop through the values returned by OCR
      for observation in observations {
        
        // make info about the position of the suspected text and add it to the info
        let box = W3WOcrRect()
        box.x = Int(observation.boundingBox.origin.x * lastImageResolution.width)
        box.y = Int(lastImageResolution.height - observation.boundingBox.origin.y * lastImageResolution.height - observation.boundingBox.size.height * lastImageResolution.height)
        box.width = Int(observation.boundingBox.size.width * lastImageResolution.width)
        box.height = Int(observation.boundingBox.size.height * lastImageResolution.height)
        frameInfo.boxes.append(box)
        
        for recognizedText in observation.topCandidates(1) {
          fullText += recognizedText.string + " "
        }
      }

      // check to see if all text has a three word address, maybe there was a line break
      let cleanedText = cleanInput(text: fullText)
      let candidates  = Set(w3w.findPossible3wa(text: cleanedText))
      
      for words in candidates {
        if let square = try? sdk.convertToSquare(words: words) {
          if square.coordinates != nil {

            var distance: Double?
            if let focusCoords = focus {
              distance = sdk.distance(from: focusCoords, to: square.coordinates)
            }
            
            let ocrSuggestion = W3WOcrSuggestion(words: square.words,
                                                 country: W3WBaseCountry(code: square.country?.code ?? W3WBaseLanguage.english.code),
                                                 nearestPlace: square.nearestPlace,
                                                 distanceToFocus: (distance == nil) ? nil : W3WBaseDistance(meters: distance ?? 0.0),
                                                 language: W3WBaseLanguage(locale: square.language?.locale ?? W3WBaseLanguage.english.locale))
            suggestions.append(ocrSuggestion)
          }
        }
      }
      
      // condition removed to allow empty results through for "no results" feedback
      completion(suggestions, nil)

      // only return boxes if there is only one
      if frameInfo.boxes.count > 1 {
        frameInfo.boxes = []
      }
      
      // return geometry info about the frame to anyone interested
      info(frameInfo)
    }
  }
  
  
  #else // SDK is unavailable, use only the API

  
  /// If the SDK is unavailable, then we must only use the defaul algorythm which assumes a slower call time, and caches results
  func recognizeTextHandler(request: VNRequest, error: Error?, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    recognizeTextHandlerApi(request: request, error: error, info: info, completion: completion)
  }

  
  #endif // w3w
  
  
  /// This does the work of recognising the text, optimised for using the Api - caches results, waits for calls to complete
  func recognizeTextHandlerApi(request: VNRequest, error: Error?, info: @escaping (W3WOcrInfo) -> (), completion: @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    if let observations = request.results as? [VNRecognizedTextObservation] {
      
      // prepare info on the values returned
      let frameInfo = W3WOcrInfo()
      frameInfo.droppedFrame = false
      frameInfo.boxes = [W3WOcrRect]()
      
      var fullText = ""

      // loop through the values returned by OCR
      for observation in observations {
        
        // make info about the position of the suspected text and add it to the info
        let box = W3WOcrRect()
        box.x = Int(observation.boundingBox.origin.x * lastImageResolution.width)
        box.y = Int(lastImageResolution.height - observation.boundingBox.origin.y * lastImageResolution.height - observation.boundingBox.size.height * lastImageResolution.height)
        box.width = Int(observation.boundingBox.size.width * lastImageResolution.width)
        box.height = Int(observation.boundingBox.size.height * lastImageResolution.height)
        frameInfo.boxes.append(box)

        for recognizedText in observation.topCandidates(1) {
          fullText += recognizedText.string + " "
        }
        
        // loop through each bit of text
        for recognizedText in observation.topCandidates(4) {
          let s = recognizedText.string
        
          // fix up some common misreadings by the OCR (misplaced separators and spaces and such
          let cleanedText = cleanInput(text: s)
          
          // check to see if it could be excatly a three word address
          if w3w.isPossible3wa(text: cleanedText) {
            foundSomething(text: cleanedText, completion: completion)
            
          } else {
            // otehrwise we scan the text to see if a 3wa is somewhere in it
            let twas = w3w.findPossible3wa(text: cleanedText)
            
            // loop through the text found by the search regex
            for text in twas {

              // check for exact match
              if w3w.isPossible3wa(text: text) {
                foundSomething(text: text, completion: completion)

              // if the text was close, fix it up again and try again
              } else if w3w.didYouMean(text: text) {
                let text = make3waFromAlmost3wa(text: text)
                foundSomething(text: text, completion: completion)
                
              // nothing found
              } else {
                //print("OCR SKIPPED: ", "[\(s)]", text)
              }
              
            }
          }
        }
      }
      
      // BETA - check to see if all text has a three word address, maybe there was a line break
      //let cleanedText = cleanInput(text: fullText)
      //for t in w3w.findPossible3wa(text: cleanedText) {
      //  foundSomething(text: t, completion: completion)
      //}
      
      // only return boxes if there is only one
      if frameInfo.boxes.count > 1 {
        frameInfo.boxes = []
      }
      
      // return geometry info about the frame to anyone interested
      info(frameInfo)
    }
  }
  
  
  /// fix up common OCR reading problems
  func cleanInput(text: String) -> String {
    var t = text //.replacingOccurrences(of: ",", with: ".")
    
    t = t.replacingOccurrences(of: "  .", with: ".")
    t = t.replacingOccurrences(of: " . ", with: ".")
    t = t.replacingOccurrences(of: ". ", with: ".")
    t = t.replacingOccurrences(of: " .", with: ".")
    
    t = t.replacingOccurrences(of: "...", with: ".")
    t = t.replacingOccurrences(of: "..", with: ".")

    t = t.lowercased()
    
    return t.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  
  /// there are never numbers (yet) in a three word address, so it's useful to scan for them
  func containsNumbers(text: String) -> Bool {
    let range = text.rangeOfCharacter(from: .decimalDigits)
    return (range == nil ? false : true)
  }
  

  /// use the regex to tease out three words if possible
  func make3waFromAlmost3wa(text: String) -> String {
    let regex   = try! NSRegularExpression(pattern: W3WRegex.regex_3wa_word)
    let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in:text))
    
    var words = [String]()
    for match in matches {
      let word = String(text[Range(match.range, in: text)!])
      words.append(word)
    }
    
    return words.joined(separator: ".")
  }
  
  
  /// called when a three word address candidate is found.  This
  /// caches the results of each call to reduce the total number of calls
  func foundSomething(text: String, completion:  @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    if !containsNumbers(text: text) {
      
      var needToCallApi = true

      // if the answer was cached then use the cached answer
      if let entry = W3WOcrNative.suggestionCache[text] { // if convertToCoordinates has already been called on this text string
        if entry.0 {                         // if the call was successful
          needToCallApi = false              // then we don't need to make another call for the same text
          if let suggestion = entry.1 {      // if there is an associated W3WOcrSuggestion
            completion([suggestion], nil)    // then return it
          }
        }
      }
      
      // if the answer was not cached we make the call
      if needToCallApi {
        if W3WOcrNative.callingC2C == false {
          callW3w(text: text, completion: completion)
        }
      }
    }
  }
  

  /// calls the API with the candidate text, and caches the results to prevent future calls
  /// on the same test string
  func callW3w(text: String, completion:  @escaping ([W3WOcrSuggestion], W3WOcrError?) -> ()) {
    W3WOcrNative.callingC2C = true

    var options = [W3WOption]()
    
    if let f = focus {
      options.append(.focus(f))
    }
    
    w3w.autosuggest(text: text, options: options) { suggestions, error in
      W3WOcrNative.callingC2C = false
      
      // pass on any error
      if let e = error {
        completion([], W3WOcrError.coreError(message: e.description))
        
      // take the first result.  If the 3wa exists, it will be the first result
      } else if let s = suggestions?.first {
        
        // make a OcrSuggestion
        if s.words == text {
          let ocrSuggestion: W3WOcrSuggestion
          ocrSuggestion = W3WOcrSuggestion(words: s.words, country: s.country, nearestPlace : s.nearestPlace, distanceToFocus: s.distanceToFocus, language: s.language)
          W3WOcrNative.suggestionCache[text] = (true, ocrSuggestion)
          completion([ocrSuggestion], nil)
          
        } else {
          // cache the result
          W3WOcrNative.suggestionCache[text] = (true, nil)
        }
      } else {
        // cache the result
        W3WOcrNative.suggestionCache[text] = (true, nil)
      }
      
    }
  }

  
  func printVersions() {
    // Check for available revisions.
    let revisions = VNRecognizeTextRequest.supportedRevisions
    
    // Get the Revision UI prefix from the menu item.
    for currentRevision in revisions {
      let currentRevisionTitle = "\(currentRevision)"
      print(currentRevisionTitle, currentRevision)
    }
    
    
    
  }
  
}
