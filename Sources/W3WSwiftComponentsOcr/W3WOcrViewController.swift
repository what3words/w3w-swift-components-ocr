//
//  W3WOcrScannerViewController.swift
//  TestOCR
//
//  Created by Dave Duprey on 04/06/2021.
//

import UIKit
import W3WSwiftCore
import W3WSwiftDesign
import CoreLocation

#if canImport(W3WOcrSdk)
import W3WOcrSdk
#endif // W3WOcrSdk

/// setting as to whether this should halt automatically when an address is found, or to continue
public enum W3WOcrScanMode {
  case continuous
  case stopOnFirstResult
}


public enum W3WOcrState: String, CaseIterable {
  case idle
  case detecting
  case scanning
  case scanned
  case error
}


#if !targetEnvironment(macCatalyst)
@available(*, deprecated, message: "use W3WOcrViewController instead")
public typealias W3WOcrScannerViewController = W3WOcrViewController
#endif

/// component for three word address OCR scanning
@available(macCatalyst 14.0, *)
open class W3WOcrViewController: W3WViewController {
  
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
  
  /// Called when the user selects a suggestion
  public var onRowSelected: ((_ item: W3WSuggestion, _ indexPath: IndexPath) -> Void)? {
    didSet {
      if let onRowSelected = onRowSelected {
        bottomSheet.tableViewController.onRowSelected = onRowSelected
      }
    }
  }
  
  /// callback closure for any errors occurring
  public var onError: (W3WError) -> () = { _ in }
  
  /// callback for when the camera gets interupted, perhaps by a phone call, etc...
  public var onInteruption: () -> () = { }
  
  /// indicates it's current state: scanning/stopped
  public var state = W3WOcrState.idle {
    didSet {
      onStateChanged()
    }
  }
  
  // camera
  var camera: W3WOcrCamera?
  
  /// the ocr system
  var ocr: W3WOcrProtocol?
  
  /// optional w3w query engine
  var w3w: W3WProtocolV4?
  
  /// UILabel for when a address is found
  var wordsLabel: W3WOcrScannerAddressLabel?
  
  /// Current user location
  var currentLocation: CLLocationCoordinate2D?
  
  /// flag to express whether to present autosuggest results
//  var showAutosuggest = false
  
  /// by default we stop scanning when one result is produced
  public var scanMode: W3WOcrScanMode = .continuous
  
  /// ensures output is stopped, as there can be suggestion stragglers
  var stopOutput = false

  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  var customCrop: CGRect?
  
  /// Unique collection of suggestions
  public var uniqueOcrSuggestions: Set<String> = []
  
  // MARK: - UI properties
  open lazy var bottomSheet: W3WSuggessionsBottomSheet = {
    let bottomSheet = W3WSuggessionsBottomSheet(theme: theme?.with(cornerRadius: .soft).with(background: .white))
    return bottomSheet
  }()
  
  open lazy var closeButton: UIButton = {
    let scheme: W3WScheme = .standard.with(colors: .standardButtonFilled)
    let button = W3WButton(icon: W3WIconView(image: .close, scheme: scheme))
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(didTouchCloseButton), for: .touchUpInside)
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: closeButtonSize),
      button.widthAnchor.constraint(equalToConstant: closeButtonSize)
    ])
    return button
  }()
  
  open lazy var errorView: W3WOcrErrorView = {
    let view = W3WOcrErrorView()
    view.isHidden = true
    return view
  }()
  
  // MARK: - Init
  public convenience init(ocr: W3WOcrProtocol, theme: W3WTheme? = nil) {
    self.init(theme: theme)
    set(ocr: ocr)
  }
  
  
#if canImport(W3WOcrSdk)
  public convenience init(ocr: W3WOcr, theme: W3WTheme? = nil) {
    self.init(theme: theme)
    set(ocr: ocr)
  }
#endif // W3WOcrSdk
  
  /// initializer override to instantiate the W3WOcrScannerView
  public override init(theme: W3WTheme? = nil) {
    super.init(theme: theme)
    setup()
  }
  
  /// initializer override to instantiate the `W3WOcrScannerView`
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  

  deinit {
    //print("OCR: OcrVC DEINIT")
  }
  
  /// Setup
  open func setup() {
    setupOcrScheme()
    W3WTranslations.main.add(bundle: Bundle.module)
  }
  
  // MARK: - View Layer
  
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
  
  // MARK: - Accessors
  
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
  public func set(_ w3w: W3WProtocolV4?) { //}, autosuggest: Bool = true) {
    if let w = w3w {
      self.w3w = w
    }
    
    //self.set(autosuggest: autosuggest)
  }
  
  public func setCurrentLocation(_ location: CLLocationCoordinate2D?) {
    currentLocation = location
  }
  
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  /// - Parameters:
  ///     - crop: camera crop to use specified in view coordinates
  public func set(crop: CGRect?) {
    self.customCrop = crop
    arrangeSubviews()
  }
  
  
    /// tell view to use autosuggest with results
    /// - Parameters:
    ///     - autosuggest: set to true to turn on autosuggest
//    public func set(autosuggest: Bool) {
//      self.showAutosuggest = autosuggest
//    }
//
//  
//    public func isUsingAutosuggest() -> Bool {
//      return showAutosuggest
//    }
  
  
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
        self.ocrView.addSubview(self.wordsLabel!)
        self.ocrView.bringSubviewToFront(self.wordsLabel!)
      }
    }
  }
  
  
  
  // MARK: - Scanning
  
  /// start scanning
  public func start() {
    stopOutput = false

    if let c = camera, let o = ocr {
      state = .scanning
      c.start()
      
      ocrView.set(camera: c)
      ocrView.set(lineColor: W3WSettings.ocrTargetColor, lineGap: 1.0)
      
      o.autosuggest(video: c) { [weak self] suggestions, error in
        if self == nil {
          print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
          
        } else if let e = error {
          DispatchQueue.main.async {
            self?.handleOcrError(e)
          }
        } else if self?.stopOutput == false {
          DispatchQueue.main.async {
            self?.handleNewSuggestions(suggestions)
          }
        }
      }
    }
  }
  
  /// Handle the first ocr suggestion, insert it on top of the bottom sheet. If it is already in the list then move it on top.
  /// - Parameters:
  ///     - suggestions: the suggestions that was found
  open func handleNewSuggestions(_ suggestions: [W3WOcrSuggestion]) {
    guard let suggestion = suggestions.first,
          let threeWordAddress = suggestion.words else {
      return
    }
    // Check for inserting or moving
    if uniqueOcrSuggestions.contains(threeWordAddress) {
      handleDuplicatedSuggestion(suggestion)
      return
    } else {
      uniqueOcrSuggestions.insert(threeWordAddress)
    }
    // Perform autosuggest just when there is w3w
    if let w3w = w3w {
      autosuggest(w3w: w3w, text: threeWordAddress) { [weak self] result in
        switch result {
        case .success(let autoSuggestion):
          let result = autoSuggestion ?? suggestion
          self?.insertMoreSuggestions([result])
          self?.onSuggestions([result])
        case .failure(let error):
          self?.showErrorView(title: error.description)
        }
      }
      return
    }
    onSuggestions([suggestion])
  }
  
  /// Autosuggest handled by some W3WProtocolV4
  /// - Parameters:
  ///     - text: the w3w address text
  func autosuggest(w3w: W3WProtocolV4,
                   text: String,
                   options: [W3WOption]? = nil,
                   completion: ((Result<W3WOcrSuggestion?, W3WError>) -> Void)?) {
    var ops: [W3WOption] = options ?? []
    if ops.isEmpty {
      ops = [.numberOfResults(1)]
      if let currentLocation = currentLocation {
        ops.append(.focus(currentLocation))
      }
    }
    w3w.autosuggest(text: text, options: options) { suggestions, error in
      if let firstSuggestion = suggestions?.first {
        let result = W3WOcrSuggestion(words: firstSuggestion.words, country: firstSuggestion.country, nearestPlace: firstSuggestion.nearestPlace, distanceToFocus: firstSuggestion.distanceToFocus, language: firstSuggestion.language)
        completion?(.success(result))
        return
      }
      if let error = error {
        completion?(.failure(error))
        return
      }
      completion?(.success(nil))
    }
  }
  
  open func handleDuplicatedSuggestion(_ suggestion: W3WSuggestion) {
    // TODO: Handle duplicated suggestion
  }
  
  /// Handle OCR error
  open func handleOcrError(_ error: W3WOcrError) {
    showErrorView(title: error.description)
    onError(W3WError.message(error.description))
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
  
  
  // MARK: - UIViewController overrides
  
  /// assign the callback closure on view load
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  /// make sure all sub views are in the right places
  open override func viewWillLayoutSubviews() {
    arrangeSubviews()
  }
  
  func arrangeSubviews() {
    if let crop = customCrop {
      ocrView.set(crop: crop)
    } else {
      let inset = W3WSettings.ocrCropInset
      let size = UIScreen.main.bounds.width - inset * 2.0
      let crop = CGRect(origin: CGPoint(x: (view.frame.width - size) / 2, y: closeButton.frame.origin.y + closeButtonSize + W3WMargin.medium.value), size: CGSize(width: size, height: size))
      ocrView.set(crop: crop)
    }
    
    // reposition the three word address if present
    updateWordsLabel()
    
    // update bottom sheet
    updateBottomSheet()
    
    // setup error view
    setupErrorView()
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    stop()
  }
  
  /// Setup UI
  open func setupUI() {
    addCloseButton()
  }
  
  /// Close button setup
  open var shouldShowCloseButton: Bool {
    return isPresentedModally()
  }
  
  open var closeButtonSize: CGFloat {
    return shouldShowCloseButton ? 48.0 : 0.0
  }
  
  open func addCloseButton() {
    guard shouldShowCloseButton else {
      return
    }
    view.addSubview(closeButton)
    NSLayoutConstraint.activate([
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: W3WMargin.medium.value)
    ])
  }
  
  @objc open func didTouchCloseButton() {
    presentingViewController?.dismiss(animated: true)
  }
  
  /// Update word label
  open func updateWordsLabel() {
    wordsLabel?.reposition(origin: CGPoint(x: ocrView.crop.origin.x, y: ocrView.crop.origin.y + ocrView.crop.size.height))
  }
  
  /// Perform actions needed on state change
  open func onStateChanged() {
    // Apply target scheme on ocr view
    let targetScheme = theme?.getOcrScheme(state: state)
    ocrView.set(scheme: targetScheme)
    bottomSheet.setState(state)
  }
}

//#endif // W3WOcrSdk
