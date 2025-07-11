//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
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
  
  /// initial height for the bottom sheet
  private let initialPanelHeight: CGFloat = 216
  
  /// the padding for ocr view
  private let ocrViewPadding: CGFloat = 35
  
  /// a binding for the viewType for the ui switch to connect with the viewModel's viewMode value
  var cameraMode: Binding<Bool> {
    Binding(
      get: { self.viewModel.viewType == .video },
      set: { newValue in self.viewModel.viewType = newValue ? .video : .still; viewModel.viewTypeSwitchEvent(on: newValue) }
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
          
          W3WCloseButtonX(onTap: viewModel.closeButtonPressed)
            .padding(.trailing, W3WPadding.heavy.value)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, W3WPadding.light.value)
        
        // Placeholder for OCR view rect
        Color.clear
          .aspectRatio(contentMode: .fit)
          .onRectChange { rect in
            viewModel.ocrCropRect.send(rect)
          }
          .overlay(W3WCornerMarkers(lineLength: 60, lineWidth: 6))
          .padding(.horizontal, ocrViewPadding)
          .padding(.vertical, W3WPadding.bold.value)
        Spacer()
      }
      
      // bottom sheet
      W3WOcrBottomSheet(
        viewModel: viewModel,
        initialPanelHeight: initialPanelHeight,
        parentHeight: contentHeight,
        scheme: viewModel.bottomSheetScheme ?? .w3wOcr,
        cameraMode: cameraMode
      )
    }
    .edgesIgnoringSafeArea(.bottom)
    .background(Color.clear)
    .onHeightChange($contentHeight, for: Height.content)
    .navigationBarHidden(true) // Fix unwanted navigation bar on iOS 15
  }
  
}
