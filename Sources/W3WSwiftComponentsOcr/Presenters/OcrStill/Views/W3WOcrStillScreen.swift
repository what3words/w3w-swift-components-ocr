//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 28/06/2025.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftDesignSwiftUI
import W3WSwiftPresenters


/// still image ocr view, showing bottom sheet
public struct W3WOcrStillScreen<ViewModel: W3WOcrStillViewModelProtocol>: View {
  /// An enum used as a unique identifier for tracking the height of different view components
  private enum Height {
    case content, image
  }
  
  /// main view model
  @ObservedObject var viewModel: ViewModel
    
  /// initial height for the bottom sheet
  private let initialHeight: CGFloat

  /// The dynamically measured height of the entire screen content,
  /// captured using `.onHeightChange(_:for: .content)`
  @State private var contentHeight: CGFloat = 0
  
  /// The dynamically measured height of the still image view,
  /// used to calculate spacing and ensure the bottom sheet does not overlap it.
  @State private var imageHeight: CGFloat = 0
  
  /// The dynamically measured height of the bottom sheet component.
  /// Helps compute safe padding and positioning relative to the image.
  @State private var bottomHeight: CGFloat

  init(viewModel: ViewModel, initialHeight: CGFloat) {
    self.viewModel = viewModel
    self.initialHeight = initialHeight
    self.bottomHeight = initialHeight
  }
  
  
  /// still image ocr view, showing bottom sheet
  public var body: some View {
    VStack(spacing: 0) {
      W3WNavigationBar(
        scheme: viewModel.scheme?
          .with(foreground: W3WColor(light: .darkBlue, dark: .white))
          .with(secondary: W3WColor(light: .black, dark: .white)),
        translations: viewModel.translations,
        onBack: viewModel.dismissButtonPressed)
      ZStack {
        W3WOcrStillImageView(viewModel: viewModel)
          .onHeightChange($imageHeight, for: Height.image)
          .frame(maxHeight: contentHeight / 2)
          .padding(.bottom, min(contentHeight - imageHeight, bottomHeight))
          .animation(.default, value: bottomHeight)
        
        W3WSuBottomSheet(
          scheme: viewModel.scheme,
          height: $bottomHeight,
          detents: W3WDetents(detents: [
            initialHeight,
            contentHeight - W3WPadding.bold.value,
            contentHeight - imageHeight - W3WPadding.bold.value
          ])) {
            if viewModel.isLoading {
              W3WProgressView(color: W3WColor.w3wLabelsPrimaryBlackInverse.uiColor)
            } else {
              W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.scheme)
            }
          }
      }
      .background(W3WCoreColor.darkBlue.suColor)
      .onHeightChange($contentHeight, for: Height.content)
    }
    .navigationBarHidden(true) // Fix unwanted navigation bar on iOS 15
  }
}
