//
//  W3WOcrScannerViewController.swift
//  TestOCR
//
//  Created by Dave Duprey on 04/06/2021.
//

import UIKit
import W3WSwiftApi

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk

/// setting as to whether this should halt automatically when an address is found, or to continue
public enum W3WOcrScanMode {
  case continuous
  case stopOnFirstResult
}


public enum W3WOcrState {
  case idle
  case detecting
  case scanning
  case error
}


#if !targetEnvironment(macCatalyst)
@available(*, deprecated, message: "use W3WOcrViewController instead")
public typealias W3WOcrScannerViewController = W3WOcrViewController
#endif

/// component for three word address OCR scanning
@available(macCatalyst 14.0, *)
open class W3WOcrViewController: UIViewController {
  
  // MARK: Vars
  
  /// callback closure for when a three word address is found - defaults to just printing out the 3wa
  lazy public var onSuggestions: ([W3WOcrSuggestion]) -> () = { _ in }
  
  /// This crazy construct is to get around an issue where Xcode15+ doesn't allow @available on variables.  In the next version this will be removed anyways.
  @available(swift, obsoleted: 4.1, renamed: "onSuggestions")
  public var onSuggestion: (W3WOcrSuggestion) -> () {
    get { return _onSuggestion }
    set { _onSuggestion = newValue }
  }
  var _onSuggestion: (W3WOcrSuggestion) -> () = { _ in }
  
  /// callback closure for any errors occurring
  public var onError: (W3WOcrError) -> () = { _ in }
  
  /// callback for when the camera gets interupted, perhaps by a phone call, etc...
  public var onInteruption: () -> () = { }
  
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle {
    didSet {
      onStateChange()
    }
  }
  
  // camera
  var camera: W3WOcrCamera?
  
  /// the ocr system
  var ocr: W3WOcrProtocol?
  
  /// optional w3w query engine
  var w3w: W3WProtocolV3?
  
  /// UILabel for when a address is found
  var wordsLabel: W3WOcrScannerAddressLabel!
  
  /// flag to express whether to present autosuggest results
  //var showAutosuggest = false
  
  /// by default we stop scanning when one result is produced
  public var scanMode = W3WOcrScanMode.stopOnFirstResult
  
  /// ensures output is stopped, as there can be suggestion stragglers
  var stopOutput = false

  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  var customCrop: CGRect?
  
  /// user defined theme, if user doesn't define another theme then use the default one
  var theme: W3WOcrTheme = .defaultTheme
  
  // MARK:- Init
  public convenience init(ocr: W3WOcrProtocol) {
    self.init()
    set(ocr: ocr)
  }
  
#if canImport(W3WOcrSdk)
  public convenience init(ocr: W3WOcr) {
    self.init()
    set(ocr: ocr)
  }
#endif // W3WOcrSdk
  
  /// initializer override to instantiate the W3WOcrScannerView
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  
  /// initializer override to instantiate the `W3WOcrScannerView`
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  

  deinit {
    //print("OCR: OcrVC DEINIT")
  }
  
  
  // MARK:- View Layer
  
  
  /// assign the `W3WOcrScannerView` to `view` when the time comes
  public override func loadView() {
    view = W3WOcrView()
  }
  
  
  /// Convenience wrapper to get layer as its statically known type.
  public var ocrView: W3WOcrView {
    if !Thread.current.isMainThread {
      print("Error: W3WOcrView not accessed from main thread")
    }
    
    return view as! W3WOcrView
  }
  
  
  func arrangeSubviews() {
    if let crop = customCrop {
      ocrView.set(crop: crop)
    } else {
      let inset = W3WSettings.ocrCropInset
      
      // calculate the crop region for portrait mode
      if ocrView.frame.width < ocrView.frame.height {
        let centerY = ocrView.frame.height * 0.44
        let width   = ocrView.frame.width - inset * 2.0
        let height  = width * W3WSettings.ocrViewfinderRatioPortrait
        let offset  = (ocrView.frame.width - width) / 2.0
        ocrView.set(crop: CGRect(x: offset, y: centerY - height / 2.0, width: width, height: height))
        
        // calculate the crop region for landscape mode
      } else {
        let centerY = ocrView.frame.height * 0.33
        let width = ocrView.frame.width * 0.8 - inset * 2.0
        let height  = width * W3WSettings.ocrViewfinderRatioLandscape
        let offset  = (ocrView.frame.width - width) / 2.0
        ocrView.set(crop: CGRect(x: offset, y: max(centerY - height / 2.0, 32.0), width: width, height: height))
      }
    }
    
    // reposition the three word address if present
    wordsLabel?.reposition(origin: CGPoint(x: self.ocrView.crop.origin.x, y: self.ocrView.crop.origin.y + self.ocrView.crop.size.height))
  }
  
  
  // MARK:- Accessors
  
  
#if canImport(W3WOcrSdk)
  /// assign the OCR SDK engine to this component by wrapping it in
  /// an object that confroms to W3WOcrProtocol
  /// - Parameters:
  ///     - ocr: the OCR engine
  public func set(ocr: W3WOcr) {
    set(ocr: W3WOcrSdkWrapper(ocr: ocr))
  }
#endif // W3WOcrSdk
  
  
  /// assign an OCR engine that conforms to W3WOcrProtocol to this component
  /// - Parameters:
  ///     - ocr: the W3WOcrProtocol conforming OCR engine
  public func set(ocr: W3WOcrProtocol?) {
    self.ocr = ocr
    
//    ocrView.set(boxStyle: .outline)
    
    if camera == nil {
      self.camera = W3WOcrCamera.get(camera: .back)
    }
  }
    
  
  /// give this view a what3words engine or api
  /// - Parameters:
  ///     - w3w: API or SDK for what3words to query with
  public func set(_ w3w: W3WProtocolV3?) { //}, autosuggest: Bool = true) {
    if let w = w3w {
      self.w3w = w
    }
    
    //self.set(autosuggest: autosuggest)
  }
  
  
  
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  /// - Parameters:
  ///     - crop: camera crop to use specified in view coordinates
  public func set(crop: CGRect?) {
    self.customCrop = crop
    arrangeSubviews()
  }
  
  
  //  /// tell view to use autosuggest with results
  //  /// - Parameters:
  //  ///     - autosuggest: set to true to turn on autosuggest
  //  public func set(autosuggest: Bool) {
  //    self.showAutosuggest = autosuggest
  //  }
  //
  //
  //  public func isUsingAutosuggest() -> Bool {
  //    return showAutosuggest
  //  }
  
  
  /// show an OCR suggestion's word on screen, under the crop
  /// - Parameters:
  ///     - suggestion: the suggestion that was found
  //  public func show(suggestion: W3WOcrSuggestion) {
  //    show(text: suggestion.words)
  //  }
  
  
  /// show a suggestion's word on screen, under the crop
  /// - Parameters:
  ///     - suggestion: the suggestion that was found
  public func show(suggestion: W3WSuggestion) {
    show(text: suggestion.words)
  }
  
  
  /// show the suggestion's word on screen, under the crop
  /// - Parameters:
  ///     - text: the text to show
  func show(text: String?) {
    DispatchQueue.main.async {
      self.wordsLabel?.removeFromSuperview()
      
      if let words = text {
        self.wordsLabel = W3WOcrScannerAddressLabel(words: words, maxWidth: self.ocrView.crop.size.width, frame: CGRect(x: self.ocrView.crop.origin.x, y: self.ocrView.crop.origin.y + self.ocrView.crop.size.height, width: self.ocrView.crop.size.width * 0.5, height: self.ocrView.crop.size.height * 0.216))
        self.ocrView.set(lineColor: W3WSettings.ocrTargetSuccess, lineGap: 0.0)
        self.ocrView.addSubview(self.wordsLabel)
        self.ocrView.bringSubviewToFront(self.wordsLabel)
      }
    }
  }
  
  
  // MARK:- Scanning
  
  
  /// start scanning
  public func start() {
    stopOutput = false

    if let c = camera, let o = ocr {
      state = .scanning
      c.start()
      
      ocrView.set(camera: c)
      ocrView.set(lineColor: W3WSettings.ocrTargetColor, lineGap: 1.0)
      show(text: nil)
      
      o.autosuggest(video: c) { [weak self] suggestions, error in
        if self == nil {
          print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
          
        } else if let e = error {
          self?.onError(e)
        
        } else if self?.stopOutput == false {
          DispatchQueue.main.async {
            self?.onSuggestions(suggestions)
          }
        }
      }
    }
  }
  
  
  /// stop scanning
  public func stop() {  // completion: @escaping () -> () = { }) {
    
    if scanMode == .stopOnFirstResult {
      stopOutput = true
    }
    
    camera?.stop()
    state = .idle

    DispatchQueue.main.async { [weak self] in
      if let c = self?.camera {
        self?.ocrView.unset(camera: c)
      }

      #if canImport(W3WOcrSdk)
      self?.ocr?.stop {
        //completion()
      }
      #endif
    
      self?.ocrView.removeBoxes()
    }
  }
  
  /// Apply target theme on state change
  public func onStateChange() {
    switch state {
    case .idle:
      ocrView.setStyle(theme.idleStyle)
    case .detecting:
      ocrView.setStyle(theme.detectingStyle)
    case .scanning:
      ocrView.setStyle(theme.scanningStyle)
    case .error:
      ocrView.setStyle(theme.errorStyle)
    }
  }
  
  // MARK:- UIVewController overrides
  
  
  /// assign the callback closure on view load
  open override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  /// make sure all sub views are in the right places
  open override func viewWillLayoutSubviews() {
    arrangeSubviews()
  }
  
  
  public override func viewWillDisappear(_ animated: Bool) {
    stop()
  }
  
}

//#endif // W3WOcrSdk
