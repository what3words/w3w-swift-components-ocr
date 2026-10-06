//
//  W3WOcrQRDetectionTests.swift
//  w3w-swift-components-ocr
//
//  Created by Au Nguyen on 28/07/2026.
//  Copyright © 2026 What3Words. All rights reserved.
//

import XCTest
@testable import W3WSwiftComponentsOcr

final class W3WOcrQRDetectionTests: XCTestCase {

  func testLiveScanAllowsDelivery() {
    XCTAssertTrue(W3WOcrQRDetection.isAllowed(viewType: .video, isTakingPhoto: false))
  }

  /// live scan has no shutter — `isTakingPhoto` cannot be true there, so it must not gate it
  func testLiveScanIgnoresTakingPhoto() {
    XCTAssertTrue(W3WOcrQRDetection.isAllowed(viewType: .video, isTakingPhoto: true))
  }

  func testPhotoPreviewAllowsDelivery() {
    XCTAssertTrue(W3WOcrQRDetection.isAllowed(viewType: .still, isTakingPhoto: false))
  }

  func testPhotoModeDeniesWhileCapturing() {
    XCTAssertFalse(W3WOcrQRDetection.isAllowed(viewType: .still, isTakingPhoto: true))
  }

  func testUploadedImageDeniesDelivery() {
    XCTAssertFalse(W3WOcrQRDetection.isAllowed(viewType: .uploaded, isTakingPhoto: false))
    XCTAssertFalse(W3WOcrQRDetection.isAllowed(viewType: .uploaded, isTakingPhoto: true))
  }

  // MARK: metadata region of interest

  func testUsableRegionPassesThrough() {
    let reported = CGRect(x: 0.1, y: 0.2, width: 0.5, height: 0.4)
    XCTAssertEqual(W3WOcrQRDetection.metadataRegionOfInterest(from: reported), reported)
  }

  /// an empty rect would switch detection OFF, unlike the crop where .zero means full frame
  func testEmptyRegionIsRejected() {
    XCTAssertNil(W3WOcrQRDetection.metadataRegionOfInterest(from: .zero))
    XCTAssertNil(W3WOcrQRDetection.metadataRegionOfInterest(from: CGRect(x: 0.5, y: 0.5, width: 0, height: 0.3)))
  }

  func testRegionIsClampedToTheUnitSquare() {
    let clamped = W3WOcrQRDetection.metadataRegionOfInterest(from: CGRect(x: -0.2, y: 0.5, width: 0.5, height: 0.8))
    // clamping recomputes edges, so compare with tolerance rather than bit-for-bit
    guard let clamped else { return XCTFail("expected a clamped region") }
    XCTAssertEqual(clamped.minX, 0, accuracy: 1e-9)
    XCTAssertEqual(clamped.minY, 0.5, accuracy: 1e-9)
    XCTAssertEqual(clamped.width, 0.3, accuracy: 1e-9)
    XCTAssertEqual(clamped.height, 0.5, accuracy: 1e-9)
  }

  func testRegionFullyOutsideTheUnitSquareIsRejected() {
    XCTAssertNil(W3WOcrQRDetection.metadataRegionOfInterest(from: CGRect(x: 1.5, y: 0.1, width: 0.3, height: 0.3)))
  }

  func testNonFiniteRegionIsRejected() {
    XCTAssertNil(W3WOcrQRDetection.metadataRegionOfInterest(from: CGRect(x: .nan, y: 0, width: 0.5, height: 0.5)))
    XCTAssertNil(W3WOcrQRDetection.metadataRegionOfInterest(from: CGRect(x: 0, y: 0, width: .infinity, height: 0.5)))
  }
}
