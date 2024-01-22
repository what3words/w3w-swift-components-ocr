import XCTest
import W3WSwiftCore
@testable import W3WSwiftComponentsOcr


final class w3w_swift_components_ocrTests: XCTestCase {
  
  // fake API to inject into tests
  var api = FakeApi()


  /// Basic test to make sure it works from begining to end
#if canImport(UIKit)
  @available(iOS 13.0, *)
  func testInstantiation() {
    let expectation = self.expectation(description: "Sanity Check")

    // make OCR view controller
    let ocrVC = W3WOcrViewController(ocr: W3WOcrNative(api))
    ocrVC.camera?.set(crop: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 300.0))
    
    // wait for image to be recognised
    ocrVC.onSuggestions = { suggestions in
      expectation.fulfill()
    }
    
    ocrVC.start()
    
    // The OCR simulated camera cycles through 4 possibilities, and the FakeApi tries
    // to match a real twa to the input.  This usually succeed within a couple seconds
    // but we use a long timeout to make a false negative a million to one chance.
    waitForExpectations(timeout: 300.0, handler: nil)
  }
#endif
}
