//
//  W3WOcrQRDetection.swift
//  w3w-swift-components-ocr
//
//  Created by Au Nguyen on 28/07/2026.
//  Copyright © 2026 What3Words. All rights reserved.
//

import Foundation
import CoreGraphics

/// Whether sighted QR codes should be delivered to the host app.
enum W3WOcrQRDetection {

  /// QR codes are delivered while the camera preview streams — live scan, or photo mode before
  /// the shutter is tapped. A captured or imported image is never scanned for codes.
  static func isAllowed(viewType: W3WOcrViewType, isTakingPhoto: Bool) -> Bool {
    switch viewType {
    case .video:
      // live scan has no shutter, so a capture can never be in flight here
      return true

    case .still:
      return !isTakingPhoto

    case .uploaded:
      return false
    }
  }


  /// The reported viewfinder region to hand to the metadata output, or nil when it is unusable.
  /// Unlike the image crop — where `.zero` means "scan the whole frame" — an empty
  /// `rectOfInterest` turns code detection OFF, so a degenerate report has to be dropped rather
  /// than applied. The preview can deliver one: its delayed report re-checks the source rect but
  /// not whether the layer is still previewing, and converting against a stopped layer gives
  /// `.zero`. AVFoundation also expects normalized coordinates, hence the clamp.
  static func metadataRegionOfInterest(from reported: CGRect) -> CGRect? {
    guard reported.origin.x.isFinite, reported.origin.y.isFinite,
          reported.width.isFinite, reported.height.isFinite,
          reported.width > 0, reported.height > 0 else {
      return nil
    }

    // pass a valid region through untouched — intersection perturbs the values it recomputes
    let unitSquare = CGRect(x: 0, y: 0, width: 1, height: 1)
    if unitSquare.contains(reported) {
      return reported
    }

    let clamped = reported.intersection(unitSquare)
    guard !clamped.isNull, clamped.width > 0, clamped.height > 0 else { return nil }

    return clamped
  }
}
