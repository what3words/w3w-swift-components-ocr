//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 02/05/2025.
//

import SwiftUI
import Combine
import W3WSwiftCore
import W3WSwiftThemes


struct W3WPanelSuggestionView: View {
  @State private var cancellable: AnyCancellable?
 
  //let suggestion: W3WSuggestion
  let suggestion: W3WSelectableSuggestion
  
  let scheme: W3WScheme?
  
  //@Binding var selected: Bool? //W3WLive<Bool>?

  var onTap: () -> ()
  
  @State var selected: Bool?


  var body: some View {
    HStack {
      if let s = selected {
        Image(uiImage: s ? W3WImage.checkmarkCircle.get() : W3WImage.circle.get())
          .padding()
      }
      
      VStack(alignment: .leading) {
        
        W3WTextView((suggestion.suggestion.words ?? "----.----.----").w3w.style(font: scheme?.styles?.font?.body).withSlashes())
          .lineLimit(1)
          .allowsTightening(true)
          .minimumScaleFactor(0.5)

        HStack {
          if suggestion.suggestion.country?.code == "ZZ" {
            W3WTextView((suggestion.suggestion.nearestPlace ?? "middle of the ocean 🐟").w3w.style(color: scheme?.colors?.secondary, font: scheme?.styles?.font?.footnote).withSlashes(color: .clear, font: scheme?.styles?.font?.body))
              .lineLimit(1)
              .allowsTightening(true)
              .minimumScaleFactor(0.5)
          } else {
            W3WTextView((suggestion.suggestion.nearestPlace ?? "middle of nowhere").w3w.style(color: scheme?.colors?.secondary, font: scheme?.styles?.font?.footnote).withSlashes(color: .clear, font: scheme?.styles?.font?.body))
              .lineLimit(1)
              .allowsTightening(true)
              .minimumScaleFactor(0.5)
          }
          Spacer()

          W3WTextView(suggestion.suggestion.distanceToFocus?.description.w3w.style(color: scheme?.colors?.secondary, font: scheme?.styles?.font?.footnote) ?? "".w3w)
            .padding(.trailing)
        }
      }
      .padding()
      
    }
    .contentShape(Rectangle())
    .onTapGesture {
      onTap()
    }
    
    .onAppear {
      cancellable = suggestion.selected
        .sink { value in
          selected = value
        }
    }
    
    .onDisappear {
      cancellable?.cancel()
    }
    
    Divider()
  }
}



#Preview {
  let s1 = W3WBaseSuggestion(words: "xxx.xxx.xxx", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s2 = W3WBaseSuggestion(words: "yyyy.yyyy.yyyy", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s3 = W3WBaseSuggestion(words: "zz.zz.zz", country: W3WBaseCountry(code: "ZZ"), nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s4 = W3WBaseSuggestion(words: "reallyreally.longverylong.threewordaddress", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))

  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s1, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s2, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s3, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s4, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s1, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s2, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s3, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s1, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s2, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s3, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s1, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s2, selected: false), scheme: .standard) { print("x") }
  W3WPanelSuggestionView(suggestion: W3WSelectableSuggestion(suggestion: s3, selected: false), scheme: .standard) { print("x") }
}
