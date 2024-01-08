//
//  W3DataTypes.swift
//  what3words
//
//  Created by Dave Duprey on 27/07/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//
//  Basic datatypes for OCR, if the W3WOcrSdk Frameword is unavailable
//  as these are defined in there
//
import Foundation
import CoreLocation
import CoreImage
import W3WSwiftCore


// If the Ocr Framework is present then these types are available through that
// If the OCR Framework is not present then we must define these here
// This project works with CoreML if the what3words OCR system is not
// available
#if canImport(W3WOcrSdk)
import W3WOcrSdk

extension W3WOcrSuggestion: W3WSuggestion {
  public var country: W3WCountry? {
    return (countryCode == nil) ? nil : W3WBaseCountry(code: countryCode!)
  }
  
  public var distanceToFocus: W3WDistance? {
    return (distanceToFocusKm == nil) ? nil : W3WBaseDistance(kilometers: distanceToFocusKm!)
  }
  
  public var language: W3WLanguage? {
    return (languageCode == nil) ? nil : W3WBaseLanguage(code: languageCode!)
  }
  
}

extension W3WOcrError {
  public var description: String {
    switch self {
    case .coreError(let message): return message
    case .unknownOcrError: return "Unknown OCR error"
    @unknown default:
      return ""
    }
  }
  
  public static func == (lhs: W3WOcrError, rhs: W3WOcrError) -> Bool {
    return lhs.description == rhs.description
  }
}

#else

public enum W3WOcrError : Error, CustomStringConvertible, Equatable {
  case unknownOcrError
  case coreError(message: String)
  
  
  public var description: String {
    switch self {
    case .coreError(let message): return message
    case .unknownOcrError: return "Unknown OCR error"
    }
  }
  
  public static func == (lhs: W3WOcrError, rhs: W3WOcrError) -> Bool {
    return lhs.description == rhs.description
  }
}


public class W3WOcrRect: NSObject {
  var x:Int = 0
  var y:Int = 0
  var width:Int = 0
  var height:Int = 0
}


public class W3WOcrInfo: NSObject {
  public var boxes: [W3WOcrRect] = [W3WOcrRect]()
  public var droppedFrame: Bool = false
}


// MARK: Enums


public struct W3WOcrBoundingBox {
  public var southWest: CLLocationCoordinate2D
  public var northEast: CLLocationCoordinate2D
  
  public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) { self.southWest = southWest; self.northEast = northEast }
}


public struct W3WOcrBoundingCircle {
  public var center: CLLocationCoordinate2D
  public var radius: Double
  
  public init(center: CLLocationCoordinate2D, radius: Double) { self.center = center; self.radius = radius }
}


/// Helper object representing a W3W grid line
public struct W3WOcrLine {
  public var start:CLLocationCoordinate2D
  public var end:CLLocationCoordinate2D
}

//
// MARK: Data types
//
//
/// Stores info about a language used with getLangauges() API call
public struct W3WOcrLanguage { //}: Hashable {
                               /// name of the language
  public var name:String
  /// name of the language in that langauge
  public var nativeName:String
  /// ISO 639-1 2 letter code
  public var code:String
  
  public init(name: String, nativeName: String, code: String) {
    self.name = name
    self.nativeName = nativeName
    self.code = code
  }
  
  public static let english = W3WOcrLanguage(name: "English", nativeName: "English", code: "en")
}


// as in the Sdk
public struct W3WOcrSuggestion: W3WSuggestion {
  public var words: String?
  public var country: W3WCountry?
  public var nearestPlace: String?
  public var distanceToFocus: W3WDistance?
  public var language: W3WLanguage?
  public var image: CGImage?
  public init() {}  /// this is to make the initializer public
  public init(words: String?, country: W3WCountry?, nearestPlace: String?, distanceToFocus: W3WDistance?, language: W3WLanguage?) {
    self.words      = words
    self.country      = country
    self.nearestPlace   = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language       = language
  }
}


/// Helper object representing a W3W place
public struct W3WOcrSquare {
  // W3WSuggestion
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: Double?
  public var language: String?
  
  // W3Square
  public var coordinates: CLLocationCoordinate2D?
  public var southWestBounds: CLLocationCoordinate2D?
  public var northEastBounds: CLLocationCoordinate2D?
  public var map: String?
}


// MARK: autosuggest options

public struct W3WOcrOptionKey {
  public static let language = "language"
  public static let voiceLanguage = "voice-language"
  public static let numberOfResults = "n-results"
  public static let focus = "focus"
  public static let numberFocusResults = "n-focus-results"
  public static let inputType = "input-type"
  public static let clipToCountry = "clip-to-country"
  public static let preferLand = "prefer-land"
  public static let clipToCircle = "clip-to-circle"
  public static let clipToBox = "clip-to-bounding-box"
  public static let clipToPolygon = "clip-to-polygon"
}


public enum W3WOcrOption {
  case language(String)
  case voiceLanguage(String)
  case numberOfResults(Int)
  case focus(CLLocationCoordinate2D)
  case numberFocusResults(Int)
  case clipToCountry(String)
  case clipToCountries([String])
  case preferLand(Bool)
  case clipToCircle(center:CLLocationCoordinate2D, radius: Double)
  case clipToBox(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)
  case clipToPolygon([CLLocationCoordinate2D])
  
  public func key() -> String {
    switch self {
    case .language:
      return W3WOcrOptionKey.language
    case .voiceLanguage:
      return W3WOcrOptionKey.voiceLanguage
    case .numberOfResults:
      return W3WOcrOptionKey.numberOfResults
    case .focus:
      return W3WOcrOptionKey.focus
    case .numberFocusResults:
      return W3WOcrOptionKey.numberFocusResults
    case .clipToCountry:
      return W3WOcrOptionKey.clipToCountry
    case .clipToCountries:
      return W3WOcrOptionKey.clipToCountry
    case .preferLand:
      return W3WOcrOptionKey.preferLand
    case .clipToCircle:
      return W3WOcrOptionKey.clipToCircle
    case .clipToBox:
      return W3WOcrOptionKey.clipToBox
    case .clipToPolygon:
      return W3WOcrOptionKey.clipToPolygon
    }
  }
  
  
  public func asString() -> String {
    switch self {
    case .language(let language):
      return language
    case .voiceLanguage(let voiceLanguage):
      return voiceLanguage
    case .numberOfResults(let numberOfResults):
      return "\(numberOfResults)"
    case .focus(let focus):
      return String(format: "%.10f,%.10f", focus.latitude, focus.longitude)
    case .numberFocusResults(let numberFocusResults):
      return "\(numberFocusResults)"
    case .clipToCountry(let clipToCountry):
      return clipToCountry
    case .clipToCountries(let countries):
      return countries.joined(separator: ",")
    case .preferLand(let preferLand):
      return preferLand ? "true" : "false"
    case .clipToCircle(let center, let radius):
      return String(format: "%.10f,%.10f,%.5f", center.latitude, center.longitude, radius)
    case .clipToBox(let southWest, let northEast):
      return String(format: "%.10f,%.10f,%.10f,%.10f", southWest.latitude, southWest.longitude, northEast.latitude, northEast.longitude)
    case .clipToPolygon(let polygon):
      var polyCoords = [String]()
      for coord in polygon {
        polyCoords.append("\(coord.latitude),\(coord.longitude)")
      }
      return polyCoords.joined(separator: ",")
      //default:
      //  return ""
    }
  }
  
  
  public func asCoordinates() -> CLLocationCoordinate2D {
    switch self {
    case .focus(let focus):
      return focus
    case .clipToCircle(let center, _):
      return center
    default:
      return CLLocationCoordinate2D()
    }
  }
  
  
  public func asBoolean() -> Bool {
    switch self {
    case .preferLand(let preference):
      return preference
    default:
      return false
    }
  }
  
  
  public func asBoundingBox() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
    switch self {
    case .clipToBox(let southWest, let northEast):
      return (northEast, southWest)
    default:
      return (CLLocationCoordinate2D(), CLLocationCoordinate2D())
    }
  }
  
  
  public func asBoundingCircle() -> (CLLocationCoordinate2D, Double) {
    switch self {
    case .clipToCircle(let center, let radius):
      return (center, radius)
    default:
      return (CLLocationCoordinate2D(), 0.0)
    }
  }
  
  
  public func asBoundingPolygon() -> [CLLocationCoordinate2D] {
    switch self {
    case .clipToPolygon(let polygon):
      return polygon
    default:
      return [CLLocationCoordinate2D]()
    }
  }
  
  
}


public class W3WOcrOptions {
  
  public var options = [W3WOcrOption]()
  
  /// this is to make the initializer public
  public init() {}
  
  public func language(_ language:String)            -> W3WOcrOptions { options.append(W3WOcrOption.language(language)); return self }
  public func voiceLangauge(_ voiceLangauge:String)  -> W3WOcrOptions { options.append(W3WOcrOption.voiceLanguage(voiceLangauge)); return self }
  public func numberOfResults(_ numberOfResults:Int) -> W3WOcrOptions { options.append(W3WOcrOption.numberOfResults(numberOfResults)); return self }
  //  public func inputType(_ inputType:W3WInputType)    -> W3WOcrOptions { options.append(W3WCoreOption.inputType(inputType)); return self }
  public func clipToCountry(_ clipToCountry:String)  -> W3WOcrOptions { options.append(W3WOcrOption.clipToCountry(clipToCountry)); return self }
  public func preferLand(_ preferLand:Bool)           -> W3WOcrOptions { options.append(W3WOcrOption.preferLand(preferLand)); return self }
  public func focus(_ focus:CLLocationCoordinate2D)     -> W3WOcrOptions { options.append(W3WOcrOption.focus(focus)); return self }
  //  public func clipToBox(_ clipToBox:W3WBoundingBox)         -> W3WOcrOptions { options.append(W3WOcrOption.clipToBox(clipToBox)); return self }
  public func numberFocusResults(_ numberFocusResults:Int)      -> W3WOcrOptions { options.append(W3WOcrOption.numberFocusResults(numberFocusResults)); return self }
  //  public func clipToCircle(_ clipToCircle:W3WBoundingCircle)       -> W3WOcrOptions { options.append(W3WOcrOption.clipToCircle(clipToCircle)); return self }
  public func clipToPolygon(_ clipToPolygon:[CLLocationCoordinate2D]) -> W3WOcrOptions { options.append(W3WOcrOption.clipToPolygon(clipToPolygon)); return self }
}


public typealias W3WOcrSuggestionsResponse          = ((_ result: [W3WOcrSuggestion]?, _ error: W3WOcrError?) -> Void)


extension W3WOcrLanguage {
  
  /// given a voice code, returns a Language struct for that language if one is supported
  /// - Parameters:
  ///     - voiceCode: voice code used by Speechmatics
  static public func getLanguageBy(code: String) -> W3WOcrLanguage? {
    var retval:W3WOcrLanguage? = nil
    
    if let language = W3WOcrLanguage.list.first(where: { $0.code == code }) {
      retval = language
    }
    
    return retval
  }
  
  
  static let list = [
    W3WOcrLanguage(name: "Abkhazian", nativeName: "аҧсуа бызшәа, аҧсшәа", code:"ab"),
    W3WOcrLanguage(name: "Afar", nativeName: "Afaraf", code: "aa"),
    W3WOcrLanguage(name: "Afrikaans", nativeName: "Afrikaans", code: "af"),
    W3WOcrLanguage(name: "Akan", nativeName: "Akan", code: "ak"),
    W3WOcrLanguage(name: "Albanian", nativeName: "Shqip", code: "sq"),
    W3WOcrLanguage(name: "Amharic", nativeName: "አማርኛ", code: "am"),
    W3WOcrLanguage(name: "Arabic", nativeName: "العربية", code: "ar"),
    W3WOcrLanguage(name: "Aragonese", nativeName: "aragonés", code: "an"),
    W3WOcrLanguage(name: "Armenian", nativeName: "Հայերեն", code: "hy"),
    W3WOcrLanguage(name: "Assamese", nativeName: "অসমীয়া", code: "as"),
    W3WOcrLanguage(name: "Avaric", nativeName: "авар мацӀ, магӀарул мацӀ", code: "av"),
    W3WOcrLanguage(name: "Avestan", nativeName: "avesta", code: "ae"),
    W3WOcrLanguage(name: "Aymara", nativeName: "aymar aru", code: "ay"),
    W3WOcrLanguage(name: "Azerbaijani", nativeName: "azərbaycan dili", code: "az"),
    W3WOcrLanguage(name: "Bambara", nativeName: "bamanankan", code: "bm"),
    W3WOcrLanguage(name: "Bashkir", nativeName: "башҡорт теле", code: "ba"),
    W3WOcrLanguage(name: "Basque", nativeName: "euskara, euskera", code: "eu"),
    W3WOcrLanguage(name: "Belarusian", nativeName: "беларуская мова", code: "be"),
    W3WOcrLanguage(name: "Bengali", nativeName: "বাংলা", code: "bn"),
    W3WOcrLanguage(name: "Bihari", nativeName: "भोजपुरी", code: "bh"),
    W3WOcrLanguage(name: "Bislama", nativeName: "Bislama", code: "bi"),
    W3WOcrLanguage(name: "Bosnian", nativeName: "bosanski jezik", code: "bs"),
    W3WOcrLanguage(name: "Breton", nativeName: "brezhoneg", code: "br"),
    W3WOcrLanguage(name: "Bulgarian", nativeName: "български език", code: "bg"),
    W3WOcrLanguage(name: "Burmese", nativeName: "ဗမာစာ", code: "my"),
    W3WOcrLanguage(name: "Catalan", nativeName: "català, valencià", code: "ca"),
    W3WOcrLanguage(name: "Chamorro", nativeName: "Chamoru", code: "ch"),
    W3WOcrLanguage(name: "Chechen", nativeName: "нохчийн мотт", code: "ce"),
    W3WOcrLanguage(name: "Chichewa", nativeName: "chiCheŵa, chinyanja", code: "ny"),
    W3WOcrLanguage(name: "Chinese", nativeName: "中文 (Zhōngwén), 汉语, 漢語", code: "zh"),
    W3WOcrLanguage(name: "Chuvash", nativeName: "чӑваш чӗлхи", code: "cv"),
    W3WOcrLanguage(name: "Cornish", nativeName: "Kernewek", code: "kw"),
    W3WOcrLanguage(name: "Corsican", nativeName: "corsu, lingua corsa", code: "co"),
    W3WOcrLanguage(name: "Cree", nativeName: "ᓀᐦᐃᔭᐍᐏᐣ", code: "cr"),
    W3WOcrLanguage(name: "Croatian", nativeName: "hrvatski jezik", code: "hr"),
    W3WOcrLanguage(name: "Czech", nativeName: "čeština, český jazyk", code: "cs"),
    W3WOcrLanguage(name: "Danish", nativeName: "dansk", code: "da"),
    W3WOcrLanguage(name: "Divehi", nativeName: "ދިވެހި", code: "dv"),
    W3WOcrLanguage(name: "Dutch", nativeName: "Vlaams", code: "nl"),
    W3WOcrLanguage(name: "Dzongkha", nativeName: "རྫོང་ཁ", code: "dz"),
    W3WOcrLanguage(name: "English", nativeName: "English", code: "en"),
    W3WOcrLanguage(name: "Esperanto", nativeName: "Esperanto", code: "eo"),
    W3WOcrLanguage(name: "Estonian", nativeName: "eesti, eesti keel", code: "et"),
    W3WOcrLanguage(name: "Ewe", nativeName: "Eʋegbe", code: "ee"),
    W3WOcrLanguage(name: "Faroese", nativeName: "føroyskt", code: "fo"),
    W3WOcrLanguage(name: "Fijian", nativeName: "vosa Vakaviti", code: "fj"),
    W3WOcrLanguage(name: "Finnish", nativeName: "suomi, suomen kieli", code: "fi"),
    W3WOcrLanguage(name: "French", nativeName: "Français", code: "fr"),
    W3WOcrLanguage(name: "Fulah", nativeName: "Fulfulde, Pulaar, Pular", code: "ff"),
    W3WOcrLanguage(name: "Galician", nativeName: "Galego", code: "gl"),
    W3WOcrLanguage(name: "Georgian", nativeName: "ქართული", code: "ka"),
    W3WOcrLanguage(name: "German", nativeName: "Deutsch", code: "de"),
    W3WOcrLanguage(name: "Greek",  nativeName: "ελληνικά", code: "el"),
    W3WOcrLanguage(name: "Guarani", nativeName: "Avañe'ẽ", code: "gn"),
    W3WOcrLanguage(name: "Gujarati", nativeName: "ગુજરાતી", code: "gu"),
    W3WOcrLanguage(name: "Haitian", nativeName: "Kreyòl ayisyen", code: "ht"),
    W3WOcrLanguage(name: "Hausa", nativeName: "هَوُسَ", code: "ha"),
    W3WOcrLanguage(name: "Hebrew", nativeName: "עברית", code: "he"),
    W3WOcrLanguage(name: "Herero", nativeName: "Otjiherero", code: "hz"),
    W3WOcrLanguage(name: "Hindi", nativeName: "हिन्दी, हिंदी", code: "hi"),
    W3WOcrLanguage(name: "Hiri Motu", nativeName: "Hiri Motu", code: "ho"),
    W3WOcrLanguage(name: "Hungarian", nativeName: "magyar", code: "hu"),
    W3WOcrLanguage(name: "Interlingua", nativeName: "Interlingua", code: "ia"),
    W3WOcrLanguage(name: "Indonesian", nativeName: "Bahasa Indonesia", code: "id"),
    W3WOcrLanguage(name: "Interlingue", nativeName: "Occidental", code: "ie"),
    W3WOcrLanguage(name: "Irish", nativeName: "Gaeilge", code: "ga"),
    W3WOcrLanguage(name: "Igbo", nativeName: "Asụsụ Igbo", code: "ig"),
    W3WOcrLanguage(name: "Inupiaq", nativeName: "Iñupiaq, Iñupiatun", code: "ik"),
    W3WOcrLanguage(name: "Ido", nativeName: "Ido", code: "io"),
    W3WOcrLanguage(name: "Icelandic", nativeName: "Íslenska", code: "is"),
    W3WOcrLanguage(name: "Italian", nativeName: "Italiano", code: "it"),
    W3WOcrLanguage(name: "Inuktitut", nativeName: "ᐃᓄᒃᑎᑐᑦ", code: "iu"),
    W3WOcrLanguage(name: "Japanese", nativeName: "日本語 (にほんご)", code: "ja"),
    W3WOcrLanguage(name: "Javanese", nativeName: "ꦧꦱꦗꦮ, Basa Jawa", code: "jv"),
    W3WOcrLanguage(name: "Kalaallisut", nativeName: "kalaallisut, kalaallit oqaasii", code: "kl"),
    W3WOcrLanguage(name: "Kannada", nativeName: "ಕನ್ನಡ", code: "kn"),
    W3WOcrLanguage(name: "Kanuri", nativeName: "Kanuri", code: "kr"),
    W3WOcrLanguage(name: "Kashmiri", nativeName: "कश्मीरी, كشميري", code: "ks"),
    W3WOcrLanguage(name: "Kazakh", nativeName: "қазақ тілі", code: "kk"),
    W3WOcrLanguage(name: "Khmer", nativeName: "ខ្មែរ, ខេមរភាសា, ភាសាខ្មែរ", code: "km"),
    W3WOcrLanguage(name: "Kikuyu", nativeName: "Gikuyu", code: "ki"),
    W3WOcrLanguage(name: "Kinyarwanda", nativeName: "Ikinyarwanda", code: "rw"),
    W3WOcrLanguage(name: "Kirghiz", nativeName: "Кыргызча, Кыргыз тили", code: "ky"),
    W3WOcrLanguage(name: "Komi", nativeName: "коми кыв", code: "kv"),
    W3WOcrLanguage(name: "Kongo", nativeName: "Kikongo", code: "kg"),
    W3WOcrLanguage(name: "Korean", nativeName: "한국어", code: "ko"),
    W3WOcrLanguage(name: "Kurdish", nativeName: "Kurdî, کوردی", code: "ku"),
    W3WOcrLanguage(name: "Kuanyama", nativeName: " Kwanyama", code: "kj"),
    W3WOcrLanguage(name: "Latin", nativeName: "lingua", code: "la"),
    W3WOcrLanguage(name: "Luxembourgish", nativeName: "Letzeburgesch", code: "lb"),
    W3WOcrLanguage(name: "Ganda", nativeName: "Luganda", code: "lg"),
    W3WOcrLanguage(name: "Limburgan", nativeName: "Limburger", code: "li"),
    W3WOcrLanguage(name: "Lingala", nativeName: "Lingála", code: "ln"),
    W3WOcrLanguage(name: "Lao", nativeName: "ພາສາລາວ", code: "lo"),
    W3WOcrLanguage(name: "Lithuanian", nativeName: "lietuvių kalba", code: "lt"),
    W3WOcrLanguage(name: "Luba-Katanga", nativeName: "Kiluba", code: "lu"),
    W3WOcrLanguage(name: "Latvian", nativeName: "latviešu valoda", code: "lv"),
    W3WOcrLanguage(name: "Manx", nativeName: "Gaelg, Gailck", code: "gv"),
    W3WOcrLanguage(name: "Macedonian", nativeName: "македонски јазик", code: "mk"),
    W3WOcrLanguage(name: "Malagasy", nativeName: "fiteny malagasy", code: "mg"),
    W3WOcrLanguage(name: "Malay", nativeName: "Bahasa Melayu, بهاس ملايو", code: "ms"),
    W3WOcrLanguage(name: "Malayalam", nativeName: "മലയാളം", code: "ml"),
    W3WOcrLanguage(name: "Maltese", nativeName: "Malti", code: "mt"),
    W3WOcrLanguage(name: "Maori", nativeName: "te reo Māori", code: "mi"),
    W3WOcrLanguage(name: "Marathi", nativeName: "मराठी", code: "mr"),
    W3WOcrLanguage(name: "Marshallese", nativeName: "Kajin M̧ajeļ", code: "mh"),
    W3WOcrLanguage(name: "Mongolian", nativeName: "Монгол хэл", code: "mn"),
    W3WOcrLanguage(name: "Nauru", nativeName: "Dorerin Naoero", code: "na"),
    W3WOcrLanguage(name: "Navajo", nativeName: " Navaho", code: "nv"),
    W3WOcrLanguage(name: "North Ndebele", nativeName: "isiNdebele", code: "nd"),
    W3WOcrLanguage(name: "Nepali", nativeName: "नेपाली", code: "ne"),
    W3WOcrLanguage(name: "Ndonga", nativeName: "Owambo", code: "ng"),
    W3WOcrLanguage(name: "Norwegian Bokmål", nativeName: "Norsk Bokmål", code: "nb"),
    W3WOcrLanguage(name: "Norwegian Nynorsk", nativeName: "Norsk Nynorsk", code: "nn"),
    W3WOcrLanguage(name: "Norwegian", nativeName: "Norsk", code: "no"),
    W3WOcrLanguage(name: "Sichuan Yi", nativeName: "ꆈꌠ꒿", code: "ii"),
    W3WOcrLanguage(name: "South Ndebele", nativeName: "isiNdebele", code: "nr"),
    W3WOcrLanguage(name: "Occitan", nativeName: "occitan, lenga d'òc", code: "oc"),
    W3WOcrLanguage(name: "Ojibwa", nativeName: "ᐊᓂᔑᓈᐯᒧᐎᓐ", code: "oj"),
    W3WOcrLanguage(name: "Church Slavic", nativeName: "ѩзыкъ словѣньскъ", code: "cu"),
    W3WOcrLanguage(name: "Oromo", nativeName: "Afaan Oromoo", code: "om"),
    W3WOcrLanguage(name: "Oriya", nativeName: "ଓଡ଼ିଆ", code: "or"),
    W3WOcrLanguage(name: "Ossetian", nativeName: "ирон æвзаг", code: "os"),
    W3WOcrLanguage(name: "Punjabi", nativeName: "ਪੰਜਾਬੀ, پنجابی", code: "pa"),
    W3WOcrLanguage(name: "Pali", nativeName: "पालि, पाळि", code: "pi"),
    W3WOcrLanguage(name: "Persian", nativeName: "فارسی", code: "fa"),
    W3WOcrLanguage(name: "Polish", nativeName: "język polski, polszczyzna", code: "pl"),
    W3WOcrLanguage(name: "Pashto", nativeName: "پښتو", code: "ps"),
    W3WOcrLanguage(name: "Portuguese", nativeName: "Português", code: "pt"),
    W3WOcrLanguage(name: "Quechua", nativeName: "Runa Simi, Kichwa", code: "qu"),
    W3WOcrLanguage(name: "Romansh", nativeName: "Rumantsch Grischun", code: "rm"),
    W3WOcrLanguage(name: "Rundi", nativeName: "Ikirundi", code: "rn"),
    W3WOcrLanguage(name: "Romanian", nativeName: "Română", code: "ro"),
    W3WOcrLanguage(name: "Russian", nativeName: "русский", code: "ru"),
    W3WOcrLanguage(name: "Sanskrit", nativeName: "संस्कृतम्", code: "sa"),
    W3WOcrLanguage(name: "Sardinian", nativeName: "sardu", code: "sc"),
    W3WOcrLanguage(name: "Sindhi", nativeName: "सिन्धी, سنڌي، سندھی", code: "sd"),
    W3WOcrLanguage(name: "Northern Sami", nativeName: "Davvisámegiella", code: "se"),
    W3WOcrLanguage(name: "Samoan", nativeName: "gagana fa'a Samoa", code: "sm"),
    W3WOcrLanguage(name: "Sango", nativeName: "yângâ tî sängö", code: "sg"),
    W3WOcrLanguage(name: "Serbian", nativeName: "српски језик", code: "sr"),
    W3WOcrLanguage(name: "Gaelic", nativeName: "Gàidhlig", code: "gd"),
    W3WOcrLanguage(name: "Shona", nativeName: "chiShona", code: "sn"),
    W3WOcrLanguage(name: "Sinhala", nativeName: "සිංහල", code: "si"),
    W3WOcrLanguage(name: "Slovak", nativeName: "Slovenčina", code: "sk"),
    W3WOcrLanguage(name: "Slovenian", nativeName: "Slovenščina", code: "sl"),
    W3WOcrLanguage(name: "Somali", nativeName: "af Soomaali", code: "so"),
    W3WOcrLanguage(name: "Southern Sotho", nativeName: "Sesotho", code: "st"),
    W3WOcrLanguage(name: "Spanish", nativeName: "Castilian", code: "es"),
    W3WOcrLanguage(name: "Sundanese", nativeName: "Basa Sunda", code: "su"),
    W3WOcrLanguage(name: "Swahili", nativeName: "Kiswahili", code: "sw"),
    W3WOcrLanguage(name: "Swati", nativeName: "SiSwati", code: "ss"),
    W3WOcrLanguage(name: "Swedish", nativeName: "Svenska", code: "sv"),
    W3WOcrLanguage(name: "Tamil", nativeName: "தமிழ்", code: "ta"),
    W3WOcrLanguage(name: "Telugu", nativeName: "తెలుగు", code: "te"),
    W3WOcrLanguage(name: "Tajik", nativeName: "тоҷикӣ, toçikī, تاجیکی", code: "tg"),
    W3WOcrLanguage(name: "Thai", nativeName: "ไทย", code: "th"),
    W3WOcrLanguage(name: "Tigrinya", nativeName: "ትግርኛ", code: "ti"),
    W3WOcrLanguage(name: "Tibetan", nativeName: "བོད་ཡིག", code: "bo"),
    W3WOcrLanguage(name: "Turkmen", nativeName: "Türkmen, Түркмен", code: "tk"),
    W3WOcrLanguage(name: "Tagalog", nativeName: "Wikang Tagalog", code: "tl"),
    W3WOcrLanguage(name: "Tswana", nativeName: "Setswana", code: "tn"),
    W3WOcrLanguage(name: "Tonga", nativeName: "Faka Tonga", code: "to"),
    W3WOcrLanguage(name: "Turkish", nativeName: "Türkçe", code: "tr"),
    W3WOcrLanguage(name: "Tsonga", nativeName: "Xitsonga", code: "ts"),
    W3WOcrLanguage(name: "Tatar", nativeName: "татар теле, tatar tele", code: "tt"),
    W3WOcrLanguage(name: "Twi", nativeName: "Twi", code: "tw"),
    W3WOcrLanguage(name: "Tahitian", nativeName: "Reo Tahiti", code: "ty"),
    W3WOcrLanguage(name: "Uighur", nativeName: "ئۇيغۇرچە", code: "ug"),
    W3WOcrLanguage(name: "Ukrainian", nativeName: "Українська", code: "uk"),
    W3WOcrLanguage(name: "Urdu", nativeName: "اردو", code: "ur"),
    W3WOcrLanguage(name: "Uzbek", nativeName: "Oʻzbek, Ўзбек, أۇزبېك", code: "uz"),
    W3WOcrLanguage(name: "Venda", nativeName: "Tshivenḓa", code: "ve"),
    W3WOcrLanguage(name: "Vietnamese", nativeName: "Tiếng Việt", code: "vi"),
    W3WOcrLanguage(name: "Volapük", nativeName: "Volapük", code: "vo"),
    W3WOcrLanguage(name: "Walloon", nativeName: "Walon", code: "wa"),
    W3WOcrLanguage(name: "Welsh", nativeName: "Cymraeg", code: "cy"),
    W3WOcrLanguage(name: "Wolof", nativeName: "Wollof", code: "wo"),
    W3WOcrLanguage(name: "Western Frisian", nativeName: "Frysk", code: "fy"),
    W3WOcrLanguage(name: "Xhosa", nativeName: "isiXhosa", code: "xh"),
    W3WOcrLanguage(name: "Yiddish", nativeName: "ייִדיש", code: "yi"),
    W3WOcrLanguage(name: "Yoruba", nativeName: "Yorùbá", code: "yo"),
    W3WOcrLanguage(name: "Zhuang, Chuang", nativeName: "Saɯ cueŋƅ, Saw cuengh", code: "za"),
    W3WOcrLanguage(name: "Zulu", nativeName: "isiZulu", code: "zu")
  ]
}


#endif
