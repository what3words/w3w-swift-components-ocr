//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 06/06/2025.
//

import SwiftUI
import W3WSwiftDesign
import W3WSwiftPresenters


struct W3WOcrBottomOverlay<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel

  let initialPanelHeight: CGFloat

  @State var detents: W3WDetents

  var cameraMode: Binding<Bool>
  
  var showButtons = true
  
  var body: some View {
    VStack {
      Spacer()
        .frame(maxHeight: .infinity)
      if showButtons {
        W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
      }
      W3WSuBottomSheet(scheme: viewModel.bottomSheetScheme, height: initialPanelHeight, detents: detents) {
        W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.bottomSheetScheme)
      }
    }
  }
}


//#Preview {
//  W3WOcrBottomOverlay()
//}
