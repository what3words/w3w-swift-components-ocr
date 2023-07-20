//
//  File.swift
//  
//
//  Created by Dave Duprey on 20/07/2023.
//

import CoreLocation
import W3WSwiftApi

// a fake API injected that returns squares that the iOS simulator will show
class FakeApi: W3WProtocolV3 {
  
  let twas = ["index.home.raft", "daring.lion.race", "oval.blast.improving", "form.monkey.employ"]
  
  var index = 0
  
  let english = W3WApiLanguage(name: "English", nativeName: "English", code: "en")
  
  func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
    incrementIndex()
    completion(makeSquare(text: words), nil)
  }
  
  func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String, completion: @escaping W3WSquareResponse) {
    incrementIndex()
    completion(makeSquare(), nil)
  }

  func autosuggest(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsResponse) {
    incrementIndex()
    completion([makeSquare(text: text)], nil)
  }

  func autosuggestWithCoordinates(text: String, options: [W3WSwiftApi.W3WOptionProtocol], completion: @escaping W3WSuggestionsWithCoordinatesResponse) {
    completion([], nil)
  }
  
  func gridSection(south_lat: Double, west_lng: Double, north_lat: Double, east_lng: Double, completion: @escaping W3WGridResponse) {
    completion([], nil)
  }
  
  func gridSection(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D, completion: @escaping W3WSwiftApi.W3WGridResponse) {
    gridSection(south_lat: southWest.latitude, west_lng: southWest.longitude, north_lat: northEast.latitude, east_lng: northEast.longitude, completion: completion)
  }
  
  func availableLanguages(completion: @escaping W3WLanguagesResponse) {
    completion([english], nil)
  }
  
  
  // MARK: Util
  
  
  func incrementIndex() {
    index += 1
    if index >= twas.count {
      index = 0
    }
  }
  

  // make a square with a likely match
  func makeSquare(text: String? = nil) -> W3WApiSquare {
    return W3WApiSquare(words: makeWords(text: text), coordinates: CLLocationCoordinate2D(latitude: 51.50998, longitude: -0.1337), country : "GB", nearestPlace : "Bayswater, UK", distanceToFocus : 1.0, language : "en")
  }

  
  // get a three word address that is the same length as the imput
  func makeWords(text: String?) -> String {
    if let t = text {
      for twa in twas {
        if twa.count == t.count {
          return twa
        }
      }
    }

    return twas[index]
  }
  
  
}
