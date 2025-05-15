//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 13/05/2025.
//

import SwiftUI
import Combine

struct W3WOcrBottomSheet<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel
  
  let initialPanelHeight: CGFloat

  var cameraMode: Binding<Bool>

  @State var detents: W3WDetents

  
  var body: some View {
    VStack {
      Spacer()
        .frame(maxHeight: .infinity)
      W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
      W3WSuBottomSheet(scheme: viewModel.scheme, height: initialPanelHeight, detents: detents) {
        W3WPanelScreen(viewModel: viewModel.panelViewModel)
      }
    }
    .background(Color.gray)
  }
}



//#Preview {
//  W3WOcrBottomSheet()
//}
