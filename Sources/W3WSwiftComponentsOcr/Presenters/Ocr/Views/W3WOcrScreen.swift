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
  
  /// initial height for the bottom sheet
  let initialPanelHeight: CGFloat

  /// the OCR UIIvew
  let ocrView: W3WOcrView
  
  /// The dynamically measured height of the entire screen content,
  /// captured using `.onHeightChange(_:for: .content)`
  @State private var contentHeight: CGFloat = 0
  
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
        
      // bottom sheet
      VStack {
        Spacer()
          .frame(maxHeight: .infinity)
        W3WOcrBottomSheet(
          viewModel: viewModel,
          initialPanelHeight: initialPanelHeight,
          parentHeight: contentHeight,
          scheme: viewModel.bottomSheetScheme ?? .w3wOcr,
          cameraMode: cameraMode
        )
      }
      
      // Add the Close Button here
      VStack {
        ZStack {
          HStack {
            Image(uiImage: W3WImage.w3wLogoWithText.get(size: W3WIconSize(value: CGSize(width: 128, height: 21.0))))
              .colorInvert()
          }

          HStack {
            Spacer() // Pushes the button to the right
            W3WCloseButtonX() {
              viewModel.closeButtonPressed()
            }
//            Button {
//              viewModel.closeButtonPressed()
//            } label: {
//              Image(systemName: "xmark.circle.fill")
//                .font(.largeTitle)
//                .foregroundColor(W3WCoreColor(hex: 0x4B7189).suColor)
//                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
//                .padding(.trailing)
//            }
          }
        }
        Spacer() // Pushes the HStack (and button) to the top
      }
    }
    .edgesIgnoringSafeArea(.bottom)
    .background(Color.clear)
    .onHeightChange($contentHeight, for: Height.content)
  }
  
}

