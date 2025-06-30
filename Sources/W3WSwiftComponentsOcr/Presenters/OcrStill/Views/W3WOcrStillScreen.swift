//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 28/06/2025.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftPresenters


/// still image ocr view, showing bottom sheet
public struct W3WOcrStillScreen<ViewModel: W3WOcrStillViewModelProtocol>: View {
  
  /// main view model
  @ObservedObject var viewModel: ViewModel
    
  /// initial height for the bottom sheet
  let initialPanelHeight: CGFloat
  
  /// detents to snap the bottom sheet to
  @State var detents: W3WDetents

  
  /// still image ocr view, showing bottom sheet
  public var body: some View {
    VStack {
      VStack {

        // still image view
        W3WOcrStillImageView(viewModel: viewModel)
          .padding(.top, 32.0)
          .background(W3WCoreColor.darkBlue.suColor)
        Spacer()
          .frame(maxHeight: .infinity)
      }

      // bottom sheet
      W3WSuBottomSheet(scheme: viewModel.scheme, height: initialPanelHeight, detents: detents, content: {
        W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.scheme)
      })
    }
    .background(W3WCoreColor.darkBlue.suColor)
    .edgesIgnoringSafeArea(.all)
  }
}

