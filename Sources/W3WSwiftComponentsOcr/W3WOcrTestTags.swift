//
//  W3WOcrTestTags.swift
//  w3w-swift-components-ocr
//
//  MT-8922: Accessibility identifiers ("test tags") for UI automation.
//  Values mirror the shared W3WTestTags.csv. Tags are only applied when
//  `W3WOcrTestTags.isEnabled` is true; the host app enables this for
//  Beta / Debug builds only, so test metadata never ships to production.
//

import Foundation

public enum W3WOcrTestTags {

  /// Master switch. Off by default; the host app turns it on at startup
  /// for test-friendly builds. Set before any view is built.
  public static var isEnabled = false

  public static let root = "ocr.root"
  public static let backButton = "ocr.backButton"
  public static let viewfinder = "ocr.viewfinder"
  public static let liveScanToggle = "ocr.liveScanToggle"
  public static let liveScanLock = "ocr.liveScanLock"
  public static let importButton = "ocr.importButton"
  public static let importButtonLock = "ocr.importButton.lock"
  public static let resultsList = "ocr.resultsList"
  public static let selectAll = "ocr.selectAll"
  public static let actionButton = "ocr.actionButton"
  public static func resultsListRow(_ index: Int) -> String { "ocr.resultsList.row.\(index)" }
  public static func resultsListRadio(_ index: Int) -> String { "ocr.resultsList.radio.\(index)" }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension View {
  /// Applies `tag` as the accessibility identifier when test tags are enabled.
  /// No-op in builds where `W3WOcrTestTags.isEnabled` is false.
  func w3wOcrTestTag(_ tag: String) -> some View {
    accessibilityIdentifier(W3WOcrTestTags.isEnabled ? tag : "")
  }
}
#endif

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIView {
  /// Applies `tag` as the accessibility identifier when test tags are enabled.
  /// Does not touch any existing identifier when disabled.
  func w3wOcrTestTag(_ tag: String) {
    guard W3WOcrTestTags.isEnabled else { return }
    accessibilityIdentifier = tag
  }
}

public extension UIViewController {
  /// Tags the controller's root view when test tags are enabled.
  func w3wOcrTestTag(_ tag: String) {
    guard W3WOcrTestTags.isEnabled else { return }
    view.accessibilityIdentifier = tag
  }
}
#endif
