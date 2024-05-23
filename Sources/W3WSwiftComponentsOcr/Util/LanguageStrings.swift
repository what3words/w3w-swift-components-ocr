//
//  LanguageStrings.swift
//  W3WSwiftComponentsOcr
//
//  Created by Thy Nguyen on 24/01/2024.
//

import Foundation

class LanguageStrings {
  private static var bundle: Bundle = .current
  
  static func setLanguage(_ language: String?) {
    if let path = Bundle.main.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) {
      LanguageStrings.bundle = bundle
    } else if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) {
      LanguageStrings.bundle = bundle
    }
  }
  
  static func localized(key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: LanguageStrings.bundle, value: "", comment: "")
  }
}
