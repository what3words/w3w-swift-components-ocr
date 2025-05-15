//
//  W3WMultiPurposeItemViewModel.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import SwiftUI
import W3WSwiftCore
import W3WSwiftThemes


public class W3WPanelViewModel: W3WPanelViewModelProtocol, W3WEventSubscriberProtocol {
  public var subscriptions = W3WEventsSubscriptions()

  @Published public var items = W3WPanelItemList(items: [])

  //@Published public var scheme: W3WScheme?
  
  public var input = W3WEvent<W3WPanelInputEvent>()
  
  public var output = W3WEvent<W3WPanelOutputEvent>()
  
  public init() {
    subscribe(to: input) { [weak self] event in
      self?.handle(event: event)
    }
  }
  
  
  func handle(event: W3WPanelInputEvent) {
    switch event {
      case .add(item: let item):
        items.prepend(item: item)

      case .remove(item: let item):
        items.remove(item: item)
    }

    objectWillChange.send()
  }
  
}




//func randomWord() -> W3WString {
//  switch Int.random(in: 1 ... 3) {
//    case 1:
//      return "filled.count.soap".w3w.withSlashes()
//    case 2:
//      return "bork".w3w.style(color: Bool.random() ? .orange : .dullRed)
//    case 3:
//      return "fun ".w3w.style(color: Bool.random() ? .cranberry : .darkBlue) + "underline".w3w.style(color: Bool.random() ? .powderBlue : .blue, underlined: true)
//    default:
//      return "banana".w3w
//  }
//  
//  let opposite = toggle.value
//  toggle.send(opposite)
//}
//

//var text = W3WLive<W3WString>("hi".w3w)
//
//var button = W3WButtonData(title: "Button", onTap: { print("TAP") })
//var button2 = W3WButtonData(title: "Button2", onTap: { print("TAP") })
//var button3 = W3WButtonData(title: "Button3", onTap: { print("TAP") })
//var button4 = W3WButtonData(title: "Button24", onTap: { print("TAP") })
//
//var time = W3WLive<W3WDuration>(.seconds(42.0))
//
//var distance = W3WLive<W3WDistance>(W3WBaseDistance(furlongs: 37.5))
//
//var eta = W3WLive<Date>(Date())
//
//var suggestion = W3WBaseSuggestion(words: "filled.count.soap", nearestPlace: "Bayswater")
//
//var toggle = W3WLive<Bool>(true)
//
//var timer: Timer?


////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text), order: 0.2)
////items.add(item: .heading(text))
//items.add(item: .actionItem(icon: .tag, text: text, button))
////items.add(item: .address(address: "string", [button]))
//items.add(item: .buttons([button, button2, button3, button4], text: text))
//items.add(item: .buttons([button2, button3, button4]))
//items.add(item: .message(text))
//items.add(item: .tappableRow(icon: .docOnDoc, text: text))
//items.add(item: .tappableRow(icon: .tag, text: W3WLive<W3WString>("Add label".w3w)))
////items.add(item: .notification(W3WNotification(message: text.value)))
////items.add(item: .route(time: time, distance: distance, eta: eta, [button]))
////items.add(item: .routeFinished(suggestion))
////items.add(item: .segmentedControl([button]))
////items.add(item: .selectableSuggestion(suggestion, toggle))
////items.add(item: .suggestion(suggestion))
////items.add(item: .tappableRow(icon: .badgeFill, text: text))
////items.add(item: .title(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
////items.add(item: .heading(text))
//
//timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//  self.text.send(self.randomWord())
//}
