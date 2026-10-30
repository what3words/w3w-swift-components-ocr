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

  /// when compact, the title and back button go to the system navigation bar, e.g. so the back button sits in the vertical bar
  var usesSystemNavigationBar = false
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  init(viewModel: ViewModel, initialHeight: CGFloat, usesSystemNavigationBar: Bool = false) {
    self.viewModel = viewModel
    self.initialHeight = initialHeight
    self.bottomHeight = initialHeight
    self.usesSystemNavigationBar = usesSystemNavigationBar
  }
  
  
  /// still image ocr view, showing bottom sheet
  public var body: some View {
    VStack(spacing: 0) {
      if !showsSystemNavigationBar {
        W3WNavigationBar(
          scheme: viewModel.scheme?
            .with(foreground: W3WColor(light: .darkBlue, dark: .white))
            .with(secondary: W3WColor(light: .black, dark: .white)),
          translations: viewModel.translations,
          onBack: viewModel.dismissButtonPressed)
      }
      ZStack {
        W3WOcrStillImageView(viewModel: viewModel)
          .onHeightChange($imageHeight, for: Height.image)
          .frame(maxHeight: contentHeight / 2)
          .padding(.bottom, min(contentHeight - imageHeight, bottomHeight))
          .animation(.default, value: bottomHeight)
        
        W3WSuBottomSheet(
          scheme: viewModel.scheme,
          height: bottomSheetHeight,
          detents: W3WDetents(detents: [
            initialHeight,
            contentHeight - W3WPadding.bold.value,
            contentHeight - imageHeight - W3WPadding.bold.value
          ])) {
            if viewModel.isLoading {
              W3WProgressView()
            } else {
              W3WPanelScreen(viewModel: viewModel.panelViewModel)
            }
          }
      }
      .background(W3WCoreColor.darkBlue.suColor)
      .onHeightChange($contentHeight, for: Height.content)
    }
    .layoutDirectionFromAppearance()
    .navigationBarHidden(!showsSystemNavigationBar) // Fix unwanted navigation bar on iOS 15
    .navigationTitle(showsSystemNavigationBar ? viewModel.translations.get(id: "ocr_results_header") : "")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if showsSystemNavigationBar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: viewModel.dismissButtonPressed) {
            Image(systemName: "chevron.backward")
          }
        }
      }
    }
    // same colour as `W3WNavigationBar`
    .toolbarBackground(viewModel.scheme?.colors?.secondaryBackground?.current.suColor ?? .clear, for: .navigationBar)
    .toolbarBackground(showsSystemNavigationBar ? .visible : .automatic, for: .navigationBar)
  }
  
  private var showsSystemNavigationBar: Bool {
    usesSystemNavigationBar && horizontalSizeClass == .compact
  }
}

// MARK: - Helpers
private extension W3WOcrStillScreen {
  var bottomSheetHeight: Binding<CGFloat>? {
    if viewModel.hasSuggestions {
      return $bottomHeight
    }
    return nil
  }
}
