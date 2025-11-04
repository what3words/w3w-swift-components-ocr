//
//  W3WAppEventName+.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 06/07/2025.
//

import W3WSwiftAppEvents


public extension W3WAppEventName {
    
  // MARK: Ocr Events
  
  static let proPaywallOcrPhotoImport: W3WAppEventName = "ocr.pro_paywall_ocr_photo_import" // non-Pro users  Defined under Paywall section.
  static let proPaywallOcrLiveScan: W3WAppEventName   = "ocr.pro_paywall_ocr_live_scan"    // non-Pro users  Defined under Paywall section.
  static let ocrPhotoImport: W3WAppEventName          = "ocr.photo_import"                // Pro users  Triggered when user clicks the import photo button while it is unlocked on the OCR main screen.
  //static let ocrLiveScan: W3WAppEventName             = "ocr.live_scan"                  // Pro users  Triggered when user clicks on Live Scan while it is unlocked on the OCR main screen.
  static let ocrLiveScanOff: W3WAppEventName          = "ocr.live_scan_off"             // Pro users  Triggered when user toggles on Live scan on the OCR main screen.
  static let ocrLiveScanOn: W3WAppEventName           = "ocr.live_scan_on"             // Pro users  Triggered when user toggles off Live scan on the OCR main screen.
  static let ocrPhotoCapture: W3WAppEventName         = "ocr.photo_capture"           // All users  Triggered when user clicks on the captures photo button on the OCR main screen.
  static let ocrResultPhotoImport: W3WAppEventName    = "ocr.result_photo_import"    // Pro users  Triggered when a user views OCR results after importing a photo.
  static let ocrResultPhotoCapture: W3WAppEventName   = "ocr.result_photo_capture"  // All users  Triggered when a user views OCR results after capturing a photo.
  static let ocrResultLiveScan: W3WAppEventName      = "ocr.result_live_scan"      // Pro users  Triggered when a user views OCR results after live scan.
  static let ocrNoResultFound: W3WAppEventName      = "ocr.no_result_found"       // All users  Triggered when no OCR results were found, and the message i.e. “Sorry, we could not detect any what3words address in the photo.” is shown to the user.
  static let ocrTryAgain: W3WAppEventName          = "ocr.try_again"             // All users  Triggered when users clicks the 'Try again' button after no OCR results were found.
  static let ocrResultSelect: W3WAppEventName     = "ocr.result_select"         // Pro users  Triggered when user click 'Select' on the OCR Results screen.
  static let ocrResultDeselect: W3WAppEventName   = "ocr.result_deselect"       // Triggered when a user taps the ‘Select’ button again while already in ‘Select’ mode.
  static let ocrResultSelectAll: W3WAppEventName   = "ocr.result_select_all"    // Pro users  Triggered when user click 'Select All' on the OCR Results screen.
  static let ocrResultDeselectAll: W3WAppEventName  = "ocr.result_deselect_all" // Triggered when a user taps the ‘Select All’ button again while all results are already selected.
  static let ocrSelectSave: W3WAppEventName         = "ocr.select_save"        // Pro users  Triggered when user clicks "Select", then selects three word addresses, then clicks "Save" on the OCR main screen.  three_word_address: array
  static let ocrSelectShare: W3WAppEventName       = "ocr.select_share"       // Pro users  Triggered when user clicks "Select", then selects three word addresses, then clicks "Share" on the OCR main screen.  three_word_address: array
  static let ocrSelectNavigate: W3WAppEventName   = "ocr.select_navigate"    // Pro users  Triggered when user clicks "Select", then selects three word addresses, then clicks "Map" on the OCR main screen.  three_word_address: array

  static let ocrHeaderButton: W3WAppEventName = "ocr.header_button" // when one of the select buttons is tapped
  static let ocrFooterButton: W3WAppEventName = "ocr.footer_button" // when one of the select buttons is tapped
  
}
