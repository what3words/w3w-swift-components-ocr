//
//  File.swift
//
//
//  Created by Dave Duprey on 06/12/2024.
//

import Foundation
import W3WSwiftCore


public class W3WOcrTranslations: W3WTranslationsProtocol, W3WExceptionalLanguageProtocol {
  // W3WRfcLanguage -> Localisation
  public let exceptionalCases: [String: String] = [
    "bs-Cyrl": "sr-Cyrl-BA",
    "bs-Latn": "bs",
    "sr-Latn-RS": "sr",
    "sr-Cyrl-RS": "sr-Cyrl",
    "sr-Latn-ME": "sr-Latn-ME",
    "sr-Cyrl-ME": "sr-Cyrl-ME",
    "sr-Latn" : "sr",
    "hr": "hr",
    "kk-Cyrl": "kk-Cyrl",
    "kk-Latn": "kk-Latn",
    "zh-Hans": "zh-CN",
    "zh-Hans-CN": "zh-CN",
    "mn-Latn": "mn",
    "zh-Hant-TW": "zh-TW",
    "zh-Hant-HK": "zh-HK",
    "mn-Cyrl": "mn",
    "es-ES": "es",
    "es-MX": "es",
    "fr-FR": "fr-FR",
    "fr-CA": "fr-CA",
    "pt-PT": "pt-PT",
    "pt-BR": "pt-BR",
    "en-GB": "en",
    "en-IN": "en",
    "en-AU": "en",
  ]
  
  var bundle: Bundle = .current
  
  var rfcLanguage: (any W3WRfcLanguageProtocol)?
  
  public init() {
    if #available(iOS 16, *) {
      let code = (NSLocale.current.language.languageCode?.identifier ?? "en") + "-" + (NSLocale.current.region?.identifier ?? "GB")
      rfcLanguage = W3WRfcLanguage(from: code)
    } else {
      rfcLanguage = W3WRfcLanguage(from: NSLocale.current.identifier)
    }
  }
  
  public func set(rfcLanguage: (any W3WRfcLanguageProtocol)?) {
    self.rfcLanguage = rfcLanguage
  }
  
  public func get(id: String) -> String {
    return getRfc(id: id, language: rfcLanguage)
  }

  public func getRfc(id: String) -> String {
    return getRfc(id: id, language: rfcLanguage)
  }

  public func getRfc(id: String, language: (any W3WRfcLanguageProtocol)?) -> String {
    setBundle(for: language)
    return NSLocalizedString(id, bundle: bundle, comment: id)
  }

  func setBundle(for rfcLanguage: (any W3WRfcLanguageProtocol)?) {
    guard let code = rfcLanguage?.code, !code.isEmpty else { return }
    let langCode = exceptionalCases[code] ?? code

    // Try requested language, then Base, then fall back to main bundle
    self.bundle = loadBundle(for: langCode)
               ?? loadBundle(for: "Base")
               ?? .main
  }

  private func loadBundle(for resource: String) -> Bundle? {
    guard let path = Bundle.module.path(forResource: resource, ofType: "lproj") else { return nil }
    return Bundle(path: path)
  }
  
}
