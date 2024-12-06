//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/12/2024.
//

import Foundation
import W3WSwiftCore


public class W3WOcrTranslations: W3WTranslationsProtocol {
  
  var bundle: Bundle = .current
  
  var language: W3WLanguage?
  
  
  public init() {
    var currentLangaugeCode = "en"
    
    if #available(iOS 16, *) {
      currentLangaugeCode = (NSLocale.current.language.languageCode?.identifier ?? "en") + "-" + (NSLocale.current.region?.identifier ?? "GB")
    } else {
      currentLangaugeCode = NSLocale.current.identifier ?? "en"
    }
    
    set(language: W3WBaseLanguage(locale: currentLangaugeCode))
  }
  
  
  public func set(language: W3WLanguage?) {
    self.language = language
  }
  
  
  public func get(id: String, language: W3WLanguage?) -> String {
    setBundle(for: language)
    return NSLocalizedString(id, bundle: bundle, comment: id)
  }
  
  
  /// returns the bundle containing the translations for the given device locale
  /// - Parameters:
  ///     - language: the language to translate into
  func setBundle(for language: W3WLanguage?) {
    if let lang = language?.locale ?? self.language?.locale {
      if let path = Bundle.module.path(forResource: lang, ofType: "lproj") {
        if let bundle = Bundle(path: path) {
          self.bundle = bundle
          return
        }
      }
    }
      
    if let path = Bundle.module.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) {
      self.bundle = bundle

    } else {
      self.bundle = Bundle.main
    }
  }

  
  
}
