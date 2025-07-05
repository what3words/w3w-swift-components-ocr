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
  /// An enum used as a unique identifier for tracking the height of different view components
  private enum Height {
    case buttons
  }
  
  /// main view model
  @ObservedObject var viewModel: ViewModel

  /// height to start with
  let initialPanelHeight: CGFloat

  /// this view's parent height to start with
  let parentHeight: CGFloat
  
  /// scheme to use
  var scheme: W3WScheme

  /// if the camera is live or still
  var cameraMode: Binding<Bool>
  
  /// The dynamically measured height of main buttons,
  /// captured using `.onHeightChange(_:for: .buttons)`
  @State private var buttonsHeight: CGFloat = 0
  
  /// An extra vertical spacing applied to the calculated detent heights.
  private let detentPadding: CGFloat = 25

  var body: some View {
    VStack {
      Spacer()
        .frame(maxHeight: .infinity)
      W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
        .onHeightChange($buttonsHeight, for: Height.buttons)
      W3WSuBottomSheet(
        scheme: viewModel.bottomSheetScheme,
        height: initialPanelHeight,
        detents: W3WDetents(detents: [
          initialPanelHeight,
          parentHeight / 2 - buttonsHeight - detentPadding,
          parentHeight - buttonsHeight - detentPadding
        ])) {
        W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: scheme)
      }
    }
  }
}

