//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 13/05/2025.
//

import SwiftUI
import Combine
import W3WSwiftThemes
import W3WSwiftPresenters


/// bottom sheet containing action buttons and a panel for suggestions and footer
struct W3WOcrBottomSheet<ViewModel: W3WOcrViewModelProtocol>: View {
  
  /// main view model
  @ObservedObject var viewModel: ViewModel

  /// height to start with
  let initialPanelHeight: CGFloat

  /// scheme to use
  var scheme: W3WScheme

  /// if the camera is live or still
  var cameraMode: Binding<Bool>

  /// the detents to snap to
  @State var detents: W3WDetents

  
  var body: some View {
    VStack {
      Spacer()
        .frame(maxHeight: .infinity)
      W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
      W3WSuBottomSheet(scheme: viewModel.bottomSheetScheme, height: initialPanelHeight, detents: detents, content: {
        W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: scheme)
      })
    }
  }
}

