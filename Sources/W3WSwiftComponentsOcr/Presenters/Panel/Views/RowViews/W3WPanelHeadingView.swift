//
//  SwiftUIView.swift
//  w3w-swift-app-presenters
//
//  Created by Dave Duprey on 31/03/2025.
//

import SwiftUI
import W3WSwiftThemes


struct W3WPanelHeadingView<ViewModel: W3WPanelViewModelProtocol>: View {
  
  var title: W3WString

  var scheme: W3WScheme? = .w3w

  // view model
  @ObservedObject var viewModel: ViewModel

  var body: some View {
    HStack {
      W3WTextView(title, separator: false)
        .foregroundColor(scheme?.colors?.foreground?.suColor)
        .background(scheme?.colors?.background?.suColor)
        .padding(W3WPadding.medium.value)
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(scheme?.colors?.secondaryBackground?.suColor)
    .listRowBackground(scheme?.colors?.secondaryBackground?.suColor)
    .animation(.easeInOut(duration: 0.1))
  }
}


//#Preview {
//    SwiftUIView()
//}
