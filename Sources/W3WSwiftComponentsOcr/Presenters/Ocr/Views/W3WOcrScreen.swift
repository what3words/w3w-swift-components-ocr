//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import Combine
import W3WSwiftThemes
import W3WSwiftDesignSwiftUI
import W3WSwiftPresenters

/// the main ocr swiftui screen
public struct W3WOcrScreen<ViewModel: W3WOcrViewModelProtocol>: View {
  /// An enum used as a unique identifier for tracking the height of different view components
  private enum Height {
    case content
  }
  
  /// main view model
  @ObservedObject var viewModel: ViewModel
  
  /// the OCR UIIvew
  let ocrView: W3WOcrView
  
  /// The dynamically measured height of the entire screen content,
  /// captured using `.onHeightChange(_:for: .content)`
  @State private var contentHeight: CGFloat = 0
  
  /// The current bounding rectangle of the OCR crop area, in screen coordinates
  @State private var ocrCropRect: CGRect = .zero
  
  /// initial height for the bottom sheet
  private let initialPanelHeight: CGFloat = 216

  /// The current height of the bottom sheet (can change based on suggestion state)
  @State private var bottomSheetHeight: CGFloat = 216
  
  /// Whether the OCR system currently has suggestions to show
  @State private var hasSuggestions = false
  
  /// a binding for the viewType for the ui switch to connect with the viewModel's viewMode value
  var cameraMode: Binding<Bool> {
    Binding(
      get: { viewModel.viewType == .video },
      set: { newValue in
        viewModel.viewType = newValue ? .video : .still
        viewModel.input.send(.trackCameraMode)
      }
    )
  }
  
  public var body: some View {
    ZStack {
      // UIViewRepresentable for OCR view
      W3WSuOcrView(ocrView: ocrView)
        .edgesIgnoringSafeArea(.all)
        
      VStack {
        ZStack {
          Image(uiImage: W3WImage
            .w3wLogoWithText
            .with(colors: W3WColors(colors: W3WBasicColors(foreground: .white)))
            .get(size: W3WIconSize(value: CGSize(width: 128, height: 21.0)))
          )
          
          W3WCloseButtonX {
            viewModel.input.send(.dismiss)
          }
          .padding(.trailing, W3WPadding.heavy.value)
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, W3WPadding.light.value)
        
        // Placeholder for OCR view rect
        Color.clear
          .aspectRatio(contentMode: .fit)
          .onRectChange { rect in
            ocrCropRect = rect
            viewModel.ocrCropRect.send(rect)
          }
          .overlay(W3WCornerMarkers(lineLength: 60, lineWidth: 6))
          .padding(.horizontal, W3WMargin.four.value)
          .padding(.vertical, W3WPadding.bold.value)
        Spacer()
      }
      
      // bottom sheet
      W3WSuBottomSheet(
        scheme: viewModel.bottomSheetScheme,
        height: $bottomSheetHeight,
        detents: bottomSheetDetents,
        accessory: {
          W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
        }) {
          W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.bottomSheetScheme)
        }
        .animation(.easeIn, value: hasSuggestions)
        .onReceive(hasSuggestionsPublisher, perform: updateHasSuggestions)
    }
    .background(
      Color.clear
        .onHeightChange($contentHeight, for: Height.content)
        .edgesIgnoringSafeArea(.top)
    )
    .layoutDirectionFromAppearance()
    .navigationBarHidden(true) // Fix unwanted navigation bar on iOS 15
  }
  
}

// MARK: - Helpers
private extension W3WOcrScreen {
  var hasSuggestionsPublisher: AnyPublisher<Bool, Never> {
    viewModel.suggestions.update.map { _ in
      viewModel.suggestions.count() > 0
    }
    .eraseToAnyPublisher()
  }
  
  func updateHasSuggestions(_ flag: Bool) {
    guard hasSuggestions != flag else { return }
    
    hasSuggestions.toggle()
    // If there are suggessions, resize bottom sheet accordingly
    if hasSuggestions {
      bottomSheetHeight = middleDetent
    } else {
      bottomSheetHeight = initialPanelHeight
    }
  }
  
  var middleDetent: CGFloat {
    contentHeight - ocrCropRect.maxY - W3WMargin.two.value
  }
  
  var bottomSheetDetents: W3WDetents {
    let detents = hasSuggestions ? [middleDetent] : [initialPanelHeight, middleDetent]
    return W3WDetents(detents: detents)
  }
}
