//
//  W3WOcrScannerViewController.swift
//  TestOCR
//
//  Created by Dave Duprey on 04/06/2021.
//  Modified by Thy Nguyen 2024
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
  
  /// callback closure for when receiving OCR scanning raw suggestions
  lazy public var onReceiveRawSuggestions: ([W3WOcrSuggestion]) -> () = { _ in }
  
  /// Called when the user selects a suggestion
  public var onSuggestionSelected: ((_ item: W3WSuggestion) -> Void)? {
    didSet {
      bottomSheet.tableViewController.onRowSelected = { [weak self] suggestion, _ in
        self?.onSuggestionSelected?(suggestion)
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
  
  var translations: W3WTranslationsProtocol
  
  /// Current user location
  var currentLocation: CLLocationCoordinate2D?
  
  /// Current language
  var currentLanguage: W3WLanguage?
  
  /// by default we stop scanning when one result is produced
  public var scanMode: W3WOcrScanMode = .continuous
  
  /// ensures output is stopped, as there can be suggestion stragglers
  var stopOutput = false

  var hasStoppedScanning = false
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  var customCrop: CGRect?
  
  /// Unique collection of suggestions
  public var uniqueOcrSuggestions: Set<String> = []
  
  // MARK: - UI properties
  open lazy var bottomSheet: W3WSuggessionsBottomSheet = {
    let bottomSheet = W3WSuggessionsBottomSheet(theme: theme, translations: translations)
    return bottomSheet
  }()
  
  open lazy var closeButton: UIView = {
    var button = W3WCloseButton()

    if #available(iOS 13.0, *) {
      button = W3WCloseButton(
        imageConfiguration: UIImage.SymbolConfiguration(weight: .bold),
        onTouch: { [weak self] in
          self?.didTouchCloseButton()
        }
      )
    } else {
      button = W3WCloseButton { [weak self] in
        self?.didTouchCloseButton()
      }
    }
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: closeButtonSize),
      button.widthAnchor.constraint(equalToConstant: closeButtonSize)
    ])
    return button
  }()
  
  open lazy var w3wLogo: UIView = {
    let imageView = W3WIconView(image: .w3wLogoWithText, 
                                scheme: .standardIcons.with(foreground: .white))
                                //size: .w3wLogoWithTextIcon)
    imageView.contentMode = .scaleToFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: W3WIconSize.w3wLogoWithTextIcon.value.width),
      imageView.heightAnchor.constraint(equalToConstant: W3WIconSize.w3wLogoWithTextIcon.value.height)
    ])
    return imageView
  }()
  
  open lazy var errorView: W3WOcrErrorView = {
    let view = W3WOcrErrorView()
    view.isHidden = true
    return view
  }()
  
  // MARK: - Init
  public convenience init(ocr: W3WOcrProtocol, theme: W3WTheme? = .what3words, w3w: W3WProtocolV4? = nil, translations: W3WTranslationsProtocol = W3WOcrTranslations()) {
    self.init(theme: theme)
    self.translations = translations
    set(ocr: ocr)
    set(w3w)
  }
  
  
#if canImport(W3WOcrSdk)
  public convenience init(ocr: W3WOcr, theme: W3WTheme? = .what3words, w3w: W3WProtocolV4? = nil, translations: W3WTranslationsProtocol = W3WOcrTranslations()) {
    self.init(theme: theme)
    self.translations = translations
    set(ocr: ocr)
    set(w3w)
  }
#endif // W3WOcrSdk
  
  /// initializer override to instantiate the W3WOcrScannerView
  public init(theme: W3WTheme? = .what3words, translations: W3WTranslationsProtocol = W3WOcrTranslations()) {
    self.translations = translations
    super.init()
    set(theme: theme ?? .what3words)
    setup()
  }
  
  /// initializer override to instantiate the `W3WOcrScannerView`
  public required init?(coder aDecoder: NSCoder) {
    self.translations = W3WOcrTranslations()
    super.init(coder: aDecoder)
    set(theme: .what3words)
    setup()
  }
  

  deinit {
    //print("OCR: OcrVC DEINIT")
  }
  
  /// Setup
  open func setup() {
    W3WTranslations.main.add(bundle: Bundle.current)
  }
  
  // MARK: - View Layer
  
  /// assign the `W3WOcrScannerView` to `view` when the time comes
  public override func loadView() {
    view = W3WOcrView()
    view.backgroundColor = theme?[.ocr]?.colors?.background?.uiColor
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
      self.camera?.onCameraStarted = { [weak self, weak camera] in
        guard let self,
              let camera
        else { return }
        self.onCameraStarted()
      }
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
  
  /// assign the user's current location to this component that will be used as an autosuggesting option
  /// - Parameters:
  ///     - location: current user's location
  public func setCurrentLocation(_ location: CLLocationCoordinate2D?) {
    currentLocation = location
  }
  
  /// assign the user's current language to this component, use name for localization and locale for autosuggesting option
  /// - Parameters:
  ///     - language: current user's language code
  public func setCurrentLanguage(_ language: W3WLanguage?) {
    currentLanguage = language
    if let languageName = (language as? W3WBaseLanguage)?.name {
      (translations as? W3WOcrTranslations)?.set(language: language)
    }
  }
  
  /// assign the user's distance unit (mertic or imperial) to this component
  /// - Parameters:
  ///     - unit: user's distance unit
  public func setDistanceUnit(_ unit: W3WMeasurementSystem?) {
    guard let unit = unit else {
      return
    }
    W3WSettings.measurement = unit
  }
  
  /// assign the user's color mode to this component
  /// - Parameters:
  ///     - colorModeOverride: user's color mode to override the system color mode
  public func setColorModeOverride(_ colorModeOverride: W3WColorMode?) {
    guard let colorModeOverride = colorModeOverride else {
      return
    }
    W3WColor.set(mode: colorModeOverride)
  }
  
  /// user defined camera crop, if nil then defaults are used, if set then the camera crop is set to this (specified in view coordinates)
  /// - Parameters:
  ///     - crop: camera crop to use specified in view coordinates
  public func set(crop: CGRect?) {
    self.customCrop = crop
    arrangeSubviews()
  }
  
  // MARK: - Scanning
  
  /// start scanning
  public func start() {
    stopOutput = false
    hasStoppedScanning = false
    if let c = camera, let o = ocr {
      state = .detecting
      c.start()
      
      ocrView.set(camera: c)
      ocrView.set(lineColor: W3WCoreColor.white.uiColor, lineGap: 1.0)
      
      o.autosuggest(video: c) { [weak self] suggestions, error in
        guard let self else { return }
        if self == nil {
          print("The OCR system is connected to a W3WOcrViewController that no longer exists. Please ensure the OCR is connected to the current W3WOcrViewController.  Perhaps instantiate a new OCR when creating a new W3WOcrViewControlller.")
          
        } else if let e = error {
          DispatchQueue.main.async {
            self.handleOcrError(e)
          }
        } else if self.stopOutput == false {
          DispatchQueue.main.async {
            self.handleNewSuggestions(suggestions)
          }
        }
      }
    }
  }
  
  /// Handle the first ocr suggestion, if it's not duplicated then insert it on top of the bottom sheet.
  /// - Parameters:
  ///     - suggestions: the suggestions that was found
  open func handleNewSuggestions(_ suggestions: [W3WOcrSuggestion]) {
    guard let suggestion = suggestions.first,
          let threeWordAddress = suggestion.words else {
      return
    }
    
    state = .scanning
    onReceiveRawSuggestions([suggestion])
    
    // Check for inserting or moving
    if uniqueOcrSuggestions.contains(threeWordAddress) {
      handleDuplicatedSuggestion(suggestion)
      state = .scanned
      return
    } else {
      uniqueOcrSuggestions.insert(threeWordAddress)
    }
    
    // Perform autosuggest just when there is w3w
    if let w3w = w3w {
      autosuggest(w3w: w3w, text: threeWordAddress) { [weak self] result in
        DispatchQueue.main.async {
          switch result {
          case .success(let autoSuggestion):
            let result = autoSuggestion ?? suggestion
            guard let words = result.words else {
              return
            }
            self?.state = .scanned
            if words == threeWordAddress {
              self?.insertMoreSuggestions([result])
              self?.onSuggestions([result])
            } else {
              // Handle when autosuggest returns different word with the original ocr suggestion
              if self?.uniqueOcrSuggestions.contains(words) ?? false {
                return
              }
              self?.uniqueOcrSuggestions.insert(words)
              self?.insertMoreSuggestions([result])
              self?.onSuggestions([result])
            }
          case .failure(let error):
            // Ignore the autosuggest error and display what the ocr provides
            self?.insertMoreSuggestions([suggestion])
            self?.onSuggestions([suggestion])
            print("autosuggest error: \((error as NSError).debugDescription)")
          }
        }
      }
      return
    }
    // Just display what the ocr provides
    state = .scanned
    insertMoreSuggestions([suggestion])
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
      if let currentLanguageLocale = currentLanguage?.locale {
        ops.append(.language(W3WBaseLanguage(locale: currentLanguageLocale)))
      }
    }
    w3w.autosuggest(text: text, options: ops) { suggestions, error in
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
    // Update state
    state = .error
    showErrorView(title: error.description)
    onError(W3WError.message(error.description))
  }
  
  /// stop scanning
  public func stop(completion: @escaping () -> () = {}) {
    if hasStoppedScanning {
      completion()
      return
    }
    hasStoppedScanning = true
    if scanMode == .stopOnFirstResult {
      stopOutput = true
    }
    
    camera?.stop()
    state = .idle

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let c = self.camera {
        self.ocrView.unset(camera: c)
      }

      self.ocrView.removeBoxes()
      
#if canImport(W3WOcrSdk)
      self.ocr?.stop {
        completion()
      }
#else
      completion()
#endif
    }
  }
  
  
  // MARK: - UIViewController overrides
  
  /// assign the callback closure on view load
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    // Trigger UI update for idle state
    state = .idle
  }
  
  /// make sure all sub views are in the right places
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    arrangeSubviews()
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  
  open override func viewDidDisappear(_ animated: Bool) {
    stop()
  }

  
  // MARK: - W3WViewController overrides
  open override func set(theme: W3WTheme?) {
    let theme = theme?.withOcrStateSchemes()
    super.set(theme: theme)
    bottomSheet.set(theme: theme)
  }
  
  // MARK: - Setup UI
  open func setupUI() {
    showHandle = false
    addCloseButton()
    addW3WLogo()
    arrangeSubviews()
  }
  
  func arrangeSubviews() {
    let oldOcrCrop = ocrView.crop
    
    // update OCR view
    setupOcrView()
    
    if ocrView.crop != oldOcrCrop {
      // update bottom sheet
      setupBottomSheet()
      
      // update error view
      setupErrorView()
    }
  }
  
  /// Setup ocr view
  func setupOcrView() {
    if let customCrop = customCrop {
      ocrView.set(crop: customCrop)
    } else {
      ocrView.set(crop: defaultCrop())
    }
  }
  
  
  func defaultCrop() -> CGRect {
    let inset = W3WSettings.ocrCropInset
    let width: CGFloat
    let height: CGFloat
    if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
      // potrait
      width = view.bounds.width - inset * 2.0
      height = width
    } else {
      // landscape
      width = view.bounds.width * 0.8 - inset * 2.0
      height = width * W3WSettings.ocrViewfinderRatioLandscape
    }
    let crop = CGRect(origin: CGPoint(x: (view.bounds.width - width) / 2,
                                      y: topMargin + closeButtonSize + W3WMargin.one.value),
                      size: CGSize(width: width, height: height))
    
    return crop
  }
  
  
  var topMargin: CGFloat {
    return shouldShowCloseButton ? closeButton.frame.minY : W3WMargin.three.value
  }
  
  /// w3w Logo
  open func addW3WLogo() {
    view.addSubview(w3wLogo)
    NSLayoutConstraint.activate([
      w3wLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      shouldShowCloseButton ? w3wLogo.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor) : w3wLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: W3WPadding.light.value)
    ])
  }
  
  /// Close button setup
  open var shouldShowCloseButton: Bool {
    return isPresentedModally()
  }
  
  open var closeButtonSize: CGFloat {
    return shouldShowCloseButton ? 60.0 : 0.0
  }
  
  open func addCloseButton() {
    guard shouldShowCloseButton else {
      return
    }
    view.addSubview(closeButton)
    NSLayoutConstraint.activate([
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ])
    closeButton.setNeedsLayout()
  }
  
  @objc open func didTouchCloseButton() {
    presentingViewController?.dismiss(animated: true)
  }
  
  /// Perform actions needed on state change
  open func onStateChanged() {
    // Apply target scheme on ocr view
    let targetScheme = theme?.getOcrScheme(state: state)
    ocrView.set(scheme: targetScheme)
    bottomSheet.setState(state)
  }
  
  /// Perform actions needed when camera has started
  open func onCameraStarted() { }
}

//#endif // W3WOcrSdk
