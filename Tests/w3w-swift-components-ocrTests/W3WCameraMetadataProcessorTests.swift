//
//  W3WCameraMetadataProcessorTests.swift
//  w3w-swift-components-ocr
//
//  Created by Au Nguyen on 11/07/2026.
//

import XCTest
@testable import W3WSwiftComponentsOcr

#if !os(tvOS) && !os(watchOS)

final class W3WCameraMetadataProcessorTests: XCTestCase {

  let start = Date(timeIntervalSince1970: 1_000_000)

  func testFirstSightingEmits() {
    let processor = W3WCameraMetadataProcessor()
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: start))
  }

  /// a code sitting in frame is reported every frame by AVFoundation — it must emit once, not once per frame
  func testSameCodeHeldInFrameEmitsOnce() {
    let processor = W3WCameraMetadataProcessor()
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: start))

    var emissions = 0
    for frame in 1...100 {
      let at = start.addingTimeInterval(Double(frame) * 0.1)
      if processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: at) {
        emissions += 1
      }
    }
    XCTAssertEqual(emissions, 0, "continuous sightings must slide the suppression window, not re-fire")
  }

  /// once the code has been out of frame past the quiet period, it may fire again
  func testSameCodeAfterQuietPeriodEmitsAgain() {
    let processor = W3WCameraMetadataProcessor()
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: start))
    let after = start.addingTimeInterval(processor.repeatSuppressionInterval + 0.1)
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: after))
  }

  func testDifferentCodeEmitsImmediately() {
    let processor = W3WCameraMetadataProcessor()
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://aaos_login?id=A", at: start))
    XCTAssertTrue(processor.shouldEmit(payload: "w3w://gas_login?id=B", at: start.addingTimeInterval(0.1)))
  }

  /// alternating codes reset the window each time — both keep being delivered (downstream dedups)
  func testAlternatingCodesEmitEachTime() {
    let processor = W3WCameraMetadataProcessor()
    XCTAssertTrue(processor.shouldEmit(payload: "A", at: start))
    XCTAssertTrue(processor.shouldEmit(payload: "B", at: start.addingTimeInterval(0.1)))
    XCTAssertTrue(processor.shouldEmit(payload: "A", at: start.addingTimeInterval(0.2)))
  }

  /// while inactive (e.g. photo mode) sightings are dropped entirely — the suppression
  /// window must not slide, so switching to live mode delivers the code immediately
  func testInactiveGateSuppressesWithoutSlidingWindow() {
    let processor = W3WCameraMetadataProcessor()
    var emitted = [String]()
    processor.onQRCode = { emitted.append($0) }

    processor.isActive = { false }
    processor.emitIfNeeded(payload: "w3w://aaos_login?id=A", at: start)
    processor.emitIfNeeded(payload: "w3w://aaos_login?id=A", at: start.addingTimeInterval(0.1))
    XCTAssertTrue(emitted.isEmpty)

    processor.isActive = { true }
    processor.emitIfNeeded(payload: "w3w://aaos_login?id=A", at: start.addingTimeInterval(0.2))
    XCTAssertEqual(emitted, ["w3w://aaos_login?id=A"])
  }

  /// active path delivers through the same duplicate suppression
  func testActiveGateEmitsOncePerSighting() {
    let processor = W3WCameraMetadataProcessor()
    var emitted = [String]()
    processor.onQRCode = { emitted.append($0) }

    processor.emitIfNeeded(payload: "A", at: start)
    processor.emitIfNeeded(payload: "A", at: start.addingTimeInterval(0.1))
    XCTAssertEqual(emitted, ["A"])
  }
}

#endif
