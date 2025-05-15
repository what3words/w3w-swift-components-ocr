//
//  SwiftUIView.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes

public struct W3WPanelScreen<ViewModel: W3WPanelViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel

  var theme: W3WTheme? = .what3words

  
  public var body: some View {
    if viewModel.items.list.count > 0 {
      ScrollView {
        ForEach((0...viewModel.items.list.count - 1), id: \.self) { index in
          switch viewModel.items.list[index] {
              
            case .heading(let text):
              W3WPanelHeadingView(title: text.value, viewModel: viewModel)
              
            case .message(let message):
              W3WPanelMessageView(message: message, viewModel: viewModel)
              
            case .actionItem(icon: let icon, text: let text, let button):
              W3WPanelActionItemView(icon: icon, text: text, button: button)
              
            case .buttons(let buttons, text: let text):
              W3WPanelButtonsView(buttons: buttons, text: text, viewModel: viewModel)
              
            case .tappableRow(icon: let image, text: let text):
              W3WPanelTappableRow(icon: image, text: text)
                
            //case .suggestion(let suggestion, let selected):
            //  W3WPanelSuggestionView(suggestion: suggestion, scheme: theme?.basicScheme(), selected: selected?.value, onTap: { print(suggestion) })
            
            case .suggestions(let suggestions):
              W3WPanelSuggestionsView(suggestions: suggestions)
              
              //  W3WPanelMessageView(message: suggestion.words ?? "", viewModel: viewModel)

              //          case .address(address: let address, let buttons):
              //            W3WPanelMessageView(message: W3WLive<W3WString>(address), viewModel: viewModel)
              //
              //          case .notification(let notification):
              //            W3WPanelMessageView(message: notification.message?.asString() ?? "", viewModel: viewModel)
              //            
              //          case .route(time: let time, distance: let distance, eta: let eta, let buttons):
              //            W3WPanelMessageView(message: time.value.seconds.description, viewModel: viewModel)
              //            
              //          case .routeFinished(let suggestion):
              //            W3WPanelMessageView(message: suggestion.words ?? "", viewModel: viewModel)
              //            
              //          case .segmentedControl(let buttons):
              //            W3WPanelMessageView(message: buttons.description, viewModel: viewModel)
              //            
              //          case .selectableSuggestion(let suggestion, let value):
              //            W3WPanelMessageView(message: (suggestion.words ?? "") + (value.value ? "on" : "off"), viewModel: viewModel)
              //
              //          case .title(let title):
              //            W3WPanelMessageView(message: title.value.asString(), viewModel: viewModel)
              
            default:
              Text("?")
          }
        }
      }
      //.animation(.default)
    }
  }
}

#Preview {
  let s1 = W3WBaseSuggestion(words: "xxx.xxx.xxx", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s2 = W3WBaseSuggestion(words: "yyyy.yyyy.yyyy", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s3 = W3WBaseSuggestion(words: "zz.zz.zz", country: W3WBaseCountry(code: "ZZ"), nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))
  let s4 = W3WBaseSuggestion(words: "reallyreally.longverylong.threewordaddress", nearestPlace: "place place placey", distanceToFocus: W3WBaseDistance(meters: 1234.0))

  var items = W3WPanelViewModel()

  W3WPanelScreen(viewModel: items)
}
