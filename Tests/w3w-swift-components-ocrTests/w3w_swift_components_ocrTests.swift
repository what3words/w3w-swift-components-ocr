import XCTest
@testable import W3WSwiftComponentsOcr

#if canImport(UIKit)
final class w3w_swift_components_ocrTests: XCTestCase {
  
  // fake API to inject into tests
  var api = FakeApi()


  /// Basic test to make sure it works from begining to end
  @available(iOS 13.0, *)
  func testWithAutosuggest() {
    let expectation = self.expectation(description: "testWithAutosuggest")

    // make OCR view controller
    let ocrVC = W3WOcrViewController(ocr: W3WOcrNative(api), w3w: api)
    ocrVC.camera?.set(crop: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 300.0))
    XCTAssertEqual(ocrVC.state, .idle)
    
    // wait for image to be recognised
    ocrVC.onReceiveRawSuggestions = { rawSuggestions in
      XCTAssertEqual(ocrVC.state, .scanning)
      XCTAssertFalse(rawSuggestions.isEmpty)
    }
    
    ocrVC.onSuggestions = { suggestions in
      XCTAssertEqual(ocrVC.state, .scanned)
      guard let firstSuggestion = suggestions.first else {
        XCTFail("Suggestions should not be empty")
        return
      }
      XCTAssertEqual(firstSuggestion.nearestPlace, "Bayswater, UK")
      XCTAssertEqual(firstSuggestion.language?.code, "en")
      XCTAssertEqual(firstSuggestion.country?.code, "GB")
      XCTAssertEqual(firstSuggestion.distanceToFocus?.kilometers, 1.0)
      expectation.fulfill()
    }
    
    ocrVC.start()
    XCTAssertEqual(ocrVC.state, .detecting)
    
    // The OCR simulated camera cycles through 4 possibilities, and the FakeApi tries
    // to match a real twa to the input.  This usually succeed within a couple seconds
    // but we use a long timeout to make a false negative a million to one chance.
    waitForExpectations(timeout: 300.0, handler: nil)
  }
  
  @available(iOS 13.0, *)
  func testWithoutAutosuggest() {
    let expectation = self.expectation(description: "testWithoutAutosuggest")

    // make OCR view controller
    let ocrVC = W3WOcrViewController(ocr: W3WOcrNative(api))
    ocrVC.camera?.set(crop: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 300.0))
    XCTAssertEqual(ocrVC.state, .idle)
    
    // wait for image to be recognised
    ocrVC.onReceiveRawSuggestions = { rawSuggestions in
      XCTAssertEqual(ocrVC.state, .scanning)
      XCTAssertFalse(rawSuggestions.isEmpty)
    }
    
    ocrVC.onSuggestions = { suggestions in
      XCTAssertEqual(ocrVC.state, .scanned)
      guard let firstSuggestion = suggestions.first else {
        XCTFail("Suggestions should not be empty")
        return
      }
      XCTAssertEqual(firstSuggestion.nearestPlace, "Bayswater, UK")
      XCTAssertEqual(firstSuggestion.language?.code, "en")
      XCTAssertEqual(firstSuggestion.country?.code, "GB")
      XCTAssertEqual(firstSuggestion.distanceToFocus?.kilometers, 1.0)
      expectation.fulfill()
    }
    
    ocrVC.start()
    XCTAssertEqual(ocrVC.state, .detecting)
    
    // The OCR simulated camera cycles through 4 possibilities, and the FakeApi tries
    // to match a real twa to the input.  This usually succeed within a couple seconds
    // but we use a long timeout to make a false negative a million to one chance.
    waitForExpectations(timeout: 300.0, handler: nil)
  }
  
  @available(iOS 13.0, *)
  func testWithError() {
    let expectation = self.expectation(description: "testWithError")
    expectation.assertForOverFulfill = false
    
    // make OCR view controller
    let api = FakeApiWithError()
    let ocrVC = W3WOcrViewController(ocr: W3WOcrNative(api))
    ocrVC.camera?.set(crop: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 300.0))
    XCTAssertEqual(ocrVC.state, .idle)
    
    ocrVC.onError = { error in
      XCTAssertEqual(error.description, "Fake error")
      XCTAssertEqual(ocrVC.state, .error)
      expectation.fulfill()
    }
    
    ocrVC.start()
    XCTAssertEqual(ocrVC.state, .detecting)
    
    // The OCR simulated camera cycles through 4 possibilities, and the FakeApi tries
    // to match a real twa to the input.  This usually succeed within a couple seconds
    // but we use a long timeout to make a false negative a million to one chance.
    waitForExpectations(timeout: 300.0, handler: nil)
  }
}
#endif
