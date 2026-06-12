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
public class W3WOcrNative: W3WOcrProtocol, W3WExceptionalLanguageProtocol {
  public func availableRfcLanguages() -> [any W3WSwiftCore.W3WRfcLanguageProtocol] {
    return supportedRfcLanguages
  }
  
  
  // W3WLanguageLocale -> W3WRfcLanguage identifier
  public let exceptionalCases: [String: String]  = [
    "bs_oo_cy": "bs-Cyrl",
    "bs_oo_la": "bs-Latn",
    "zh_hk"   : "zh-Hant-HK",
    "zh_tr"   : "zh-Hant-TW",
    "zh_si"   : "zh-Hans",
    "kk_cy"   : "kk-Cyrl",
    "kk_la"   : "kk-Latn",
    "mn_cy"   : "mn-Cyrl",
    "mn_la"   : "mn-Latn",
    "me_oo_cy": "sr-Cyrl-ME",
    "me_oo_la": "sr-Latn-ME",
    "sr_oo_cy"   : "sr-Cyrl-RS",
    "sr_oo_la"   : "sr-Latn-RS"
  ]

  /// languages to use for recognition
  var languages: [String] {
    return rfcLanguages.map(\.shortIdentifier)
  }
  
  var rfcLanguages: [any W3WRfcLanguageProtocol] = [W3WRfcLanguage.default]
  
  /// lastImageResolution
  var lastImageResolution = CGSize(width: 1.0, height: 1.0)

  /// the languages this supports
//  var supportedLanguages = [String]()
  
  var supportedRfcLanguages: [any W3WRfcLanguageProtocol] = .init()
  var supportedOcrRfcLanguages: [any W3WRfcLanguageProtocol] = .init()
  
  /// Create a new request to recognize text.
  var request: VNRecognizeTextRequest?

  /// what3words api/sdk
  var w3w: W3WProtocolV4Wrapper!
  
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
  public init(_ w3w: W3WProtocolV4Wrapper) {
    configure(w3w: w3w)
  }
  
  
#if canImport(w3w)
  public init(sdk: What3Words) {
    configure(w3w: sdk as! W3WProtocolV4Wrapper)
  }
#endif // w3w

  
  func configure(w3w: W3WProtocolV4Wrapper) {
    self.w3w = w3w
    
    // get a list of langauges from the system
    let temp = VNRecognizeTextRequest(completionHandler: { _, _ in })
    if #available(iOS 15.0, *) {
      if let ocrLangauges = try? temp.supportedRecognitionLanguages() {
        self.supportedOcrRfcLanguages = ocrLangauges.compactMap { try? W3WRfcLanguage(from: $0, iOSCompatible: true) }
      }
    }
     
    // temper that list by removing any languages w3w doesn't support
    self.w3w.availableRfcLanguages { [weak self] rfcLanguages, error in
      let ocrLangs = self?.supportedOcrRfcLanguages ?? []
      if let rfcLanguages {
        self?.supportedRfcLanguages = self?.equalLanguages(ocrLanguages: ocrLangs, rfcLanguages: rfcLanguages) ?? []
      }
    }
    
//    self.w3w.availableLanguages() { languages, error in
//      if let w3wLanguages = languages {
//        let cases = self.exceptionalCases
//        let rfcLanguages: [any W3WRfcLanguageProtocol] = w3wLanguages.map { w3wLanguage in
//          let code = cases[w3wLanguage.locale] ?? w3wLanguage.locale
//          return W3WRfcLanguage(from: code)
//        }
//        self.supportedLanguages = self.w3wSupported(ocrLanguages: self.supportedLanguages, rfcLanguages: rfcLanguages)
//        
//        self.supportedRfcLanguages = self.rfcSupported(ocrLanguages: self.supportedLanguages, rfcLanguages: rfcLanguages)
//      }
//    }
  }
  
  func equalLanguages(ocrLanguages: [any W3WRfcLanguageProtocol], rfcLanguages: [any W3WRfcLanguageProtocol]) -> [any W3WRfcLanguageProtocol] {
    ocrLanguages.filter { ocr in
      rfcLanguages.contains { ocr.isEquivalent(to: $0) }
    }
  }
  
  /// returns the union of the two lists
  func w3wSupported(ocrLanguages: [String], rfcLanguages: [any W3WRfcLanguageProtocol]) -> [String] {
    var supported = [String]()

    for supportedCode in ocrLanguages {
      if w3wSupported(code: supportedCode, rfcLanguages: rfcLanguages) {
        supported.append(supportedCode)
      }
    }

    return supported
  }

  
//  /// returns the union of the two lists
//  func rfcSupported(ocrLanguages: [String], rfcLanguages: [any W3WRfcLanguageProtocol]) -> [any W3WRfcLanguageProtocol] {
//    var supported = [any W3WRfcLanguageProtocol]()
//
//    for supportedCode in ocrLanguages {
//      if let rfcLanguage = rfcSupported(code: supportedCode, rfcLanguages: rfcLanguages) {
//        supported.append(rfcLanguage)
//      }
//    }
//
//    return supported
//  }
  

  
  /// checks if a language is in a language array
   func w3wSupported(code: String, rfcLanguages: [any W3WRfcLanguageProtocol]) -> Bool {
     // Convert once — the result doesn't depend on the loop element.
     guard let convertedRfcLanguage = try? W3WRfcLanguage(from: code, iOSCompatible: true) else {
       return false
     }
     return rfcLanguages.contains { convertedRfcLanguage.identifier.contains($0.identifier) }
   }
  
  deinit {
  }
  
  
  /// Sets the language to use for scanning.
  /// - Parameters:
  ///     - language: a two letter ISO code for the language to use
  public func set(language: String) throws {
//    self.languages = [language]
  }
  
  public func set(rfcLanguage: any W3WSwiftCore.W3WRfcLanguageProtocol) throws {
    self.rfcLanguages = [rfcLanguage]
  }
  
  /// Sets the languages to use for scanning.
  /// - Parameters:
  ///     - language: an array of two letter ISO code for the language to use
  func set(languages: [String]) throws {
//    self.languages = languages
  }
  
  
  public func set(focus: CLLocationCoordinate2D?) {
    self.focus = focus
  }
  

  /// returns an array of  ISO 639-1 2 letter language codes indicating which langauges are supported
  public func availableLanguages() -> [String] {
//    return supportedLanguages
    return []
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
      request = VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
        self?.recognizeTextHandler(request: request, error: error, info: info, completion: completion)
      })
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
    self.info       = { [weak video] info in
      video?.onFrameInfo(info)
    }
    
    video.onNewImage = { [weak self] image in
      guard let self else { return }
      self.lastImageResolution = CGSize(width: image.width, height: image.height)
      self.autosuggest(image: image, info: self.info) { [weak self] suggestions, error in
        self?.completion(suggestions, error)
      }
    }
  }
  
  
  /// tell OCR to stop processing, this operating is threaded and takes time
  /// - Parameters:
  ///     - completion: called when all the OCR threads have been finally stopped
  public func stop(completion: @escaping () -> () = { }) {
    W3WOcrNative.callingC2C = false
    request = nil
    self.completion = { _,_ in }
    self.info = { _ in }
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
        guard let square = try? sdk.convertToSquare(words: words),
              let language = square.language?.code,
              languages.contains(where: { $0.hasPrefix(language) }),
              square.coordinates != nil
        else { continue }
        
        let distance: Double? = {
          guard let focus else { return nil }
          return sdk.distance(from: focus, to: square.coordinates)
        }()
        
        let ocrSuggestion = W3WOcrSuggestion(
          words: square.words,
          country: W3WBaseCountry(code: square.country?.code ?? W3WRfcLanguage.default.code ?? "en"),
          nearestPlace: square.nearestPlace,
          distanceToFocus: (distance == nil) ? nil : W3WBaseDistance(meters: distance ?? 0.0),
          language: W3WBaseLanguage(locale: square.language?.locale ?? W3WRfcLanguage.default.code ?? "en"))
        suggestions.append(ocrSuggestion)
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
      
      var scheduledAnyCalls = false
      
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
            scheduledAnyCalls = true
            foundSomething(text: cleanedText, completion: completion)
          } else {
            // otehrwise we scan the text to see if a 3wa is somewhere in it
            let twas = w3w.findPossible3wa(text: cleanedText)
            
            // loop through the text found by the search regex
            for text in twas {

              // check for exact match
              if w3w.isPossible3wa(text: text) {
                scheduledAnyCalls = true
                foundSomething(text: text, completion: completion)

              // if the text was close, fix it up again and try again
              } else if w3w.didYouMean(text: text) {
                let fixed = make3waFromAlmost3wa(text: text)
                scheduledAnyCalls = true
                foundSomething(text: fixed, completion: completion)
                
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
      
      if !scheduledAnyCalls {
        completion([], nil)
      }
    } else {
      if let err = error {
        completion([], W3WOcrError.coreError(message: err.localizedDescription))
      } else {
        completion([], nil)
      }
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
          completion([], nil)
        }
      } else {
        // cache the result
        W3WOcrNative.suggestionCache[text] = (true, nil)
        completion([], nil)
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

