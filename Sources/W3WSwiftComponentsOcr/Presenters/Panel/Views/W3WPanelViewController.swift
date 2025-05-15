//
//  W3WMultiPurposeViewController.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes
import W3WSwiftDesign
//import W3WSwiftAppEvents


open class W3WPanelViewController<ViewModel: W3WPanelViewModelProtocol>: W3WHostingViewController<W3WPanelScreen<ViewModel>> {

  /// keeps a reference to objects to keep them alive and release them on destruction
  var keepAlive: [Any?]

  @Published public var theme: W3WTheme?
  
  /// view controller containing a Settings view
  /// - Parameters:
  ///     - viewModel: the viewmodel for the view
  ///     - theme: the theme stream
  public init(viewModel: ViewModel, keepAlive: [Any?] = []) {
    let notificationView = W3WPanelScreen(viewModel: viewModel)
    self.keepAlive = keepAlive

    super.init(rootView: notificationView)
    //view.backgroundColor = .orange // affects the border in ipad mode
  }
  
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

//  override public func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    updateFrameIfNessesary()
//  }
//
//  
//  func updateFrameIfNessesary() {
//    view.invalidateIntrinsicContentSize()
//    view.setNeedsUpdateConstraints()
//    updateFrame()
//  }
//  
//  
//  func updateFrame() {
//    // if the change was more than a pixel (accounting for rounding errors), then update the view size
//    if !approximatelyEqual(this: self.view.frame, to: self.idealSize()) {
//      self.view.frame = self.idealSize()
//    }
//  }
//
//
//  /// ficure out the size of view needed to display the internal swiftui view
//  public func idealSize() -> CGRect {
//    return CGRect(
//      origin: view.frame.origin,
//      size: CGSize(
//        width: view.superview?.frame.width ?? view.frame.width,
//        height: view.intrinsicContentSize.height // intrinsicSize().height + 128.0
//      )
//    )
//  }
//  
//  @available(*, deprecated, message: "this is local but there is one in w3w-swift-app-presenters, so move it to design-swiftui and change this")
//  func approximatelyEqual(this: CGRect, to: CGRect, margin: CGFloat = 0.1) -> Bool {
//    if abs(this.origin.x - to.origin.x) < margin
//        && abs(this.origin.y - to.origin.y) < margin
//        && abs(this.size.width - to.size.width) < margin
//        && abs(this.size.height - to.size.height) < margin
//    {
//      return true
//    }
//    
//    return false
//  }

}


//==============================================


/// view controller containing a settings view
//open class W3WSettingsViewController<ViewModel: W3WSettingsViewModelProtocol>: W3WHostingViewController<W3WSettingsView<ViewModel>>,  W3WEventSubscriberProtocol {
//  public var subscriptions = W3WEventsSubscriptions()
//
//  /// keeps a reference to objects to keep them alive and release them on destruction
//  var keepAlive: [Any?]
//
//  /// view controller containing a Settings view
//  /// - Parameters:
//  ///     - viewModel: the viewmodel for the view
//  ///     - theme: the theme stream
//  public init(viewModel: ViewModel, theme: W3WLive<W3WTheme?>? = nil, keepAlive: [Any?] = []) {
//    let notificationView = W3WSettingsView(viewModel: viewModel, output: viewModel.output)
//    self.keepAlive = keepAlive
//
//    super.init(rootView: notificationView)
//    configure(notificationCount: viewModel.notificationCount)
//  }
//
//
//  /// configure the view
//  /// - Parameters:
//  ///     - notificationCount: a stream of the number of Settings, used to guess if the size changed
//  func configure(notificationCount: W3WLive<Int>) {
//    view.backgroundColor = .clear
//    //view.accessibilityIdentifier = String(reflecting: Self.self).split(separator: ".").joined(separator: ".").lowercased()
//
//    subscribe(to: notificationCount) { [weak self] count in
//      self?.updateFrameIfNessesary()
//    }
//  }
//
//
//  required dynamic public init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//
//  override public func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    updateFrameIfNessesary()
//  }
//
//  open override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//
//    self.navigationController?.setNavigationBarHidden(true, animated: false)
//  }
//
//  func updateFrameIfNessesary() {
//    view.invalidateIntrinsicContentSize()
//    view.setNeedsUpdateConstraints()
//    updateFrame()
//  }
//
//
//  func updateFrame() {
//    // if the change was more than a pixel (accounting for rounding errors), then update the view size
//    if !view.frame.approximatelyEqual(to: self.idealSize()) {
//      self.view.frame = self.idealSize()
//    }
//  }
//
//
//  /// ficure out the size of view needed to display the internal swiftui view
//  public func idealSize() -> CGRect {
//    return CGRect(
//      origin: view.frame.origin,
//      size: CGSize(
//        width: view.superview?.frame.width ?? view.frame.width,
//        height: view.intrinsicContentSize.height // intrinsicSize().height + 128.0
//      )
//    )
//  }
//}

