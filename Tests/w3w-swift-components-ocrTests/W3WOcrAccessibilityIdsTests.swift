//
//  W3WOcrAccessibilityIdsTests.swift
//  w3w-swift-components-ocr
//
//  Copyright © 2026 What3Words. All rights reserved.
//

import XCTest
@testable import W3WSwiftComponentsOcr

final class W3WOcrAccessibilityIdsTests: XCTestCase {

  func testOcrViewHasNoIdentifierByDefault() {
    let view = W3WOcrView(frame: .zero)
    XCTAssertNil(view.accessibilityIdentifier)
  }

  func testOcrViewAppliesTheHostViewfinderId() {
    let view = W3WOcrView(frame: .zero)
    view.accessibilityIds = W3WOcrAccessibilityIds(viewfinder: "custom.viewfinder")
    XCTAssertEqual(view.accessibilityIdentifier, "custom.viewfinder")
  }

  func testRowIdsComeFromTheHostClosure() {
    let ids = W3WOcrAccessibilityIds(resultsListRow: { "row-\($0)" })
    XCTAssertEqual(ids.resultsListRow?(2), "row-2")
  }
}
