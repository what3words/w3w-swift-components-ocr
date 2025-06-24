//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 30/04/2025.
//

import SwiftUI
import W3WSwiftThemes
import W3WSwiftDesign
import W3WSwiftDesignSwiftUI
import W3WSwiftPresenters


public struct W3WOcrScreen<ViewModel: W3WOcrViewModelProtocol>: View {
  
  // main view model
  @ObservedObject var viewModel: ViewModel
  
  let initialPanelHeight: CGFloat

  let ocrView: W3WOcrView
  
  @State var detents: W3WDetents
  
//  @State var cameraMode: Bool
  
//  var cameraMode: Binding<Bool> {
//  }
  
  var cameraMode: Binding<Bool> {
    Binding(
      get: {
        self.viewModel.viewType == .video
      },
      set: {
        newValue in self.viewModel.viewType = newValue ? .video : .still
        viewModel.viewTypeSwitchEvent(on: newValue)
      }
    )
  }
  
  
//  var ocrButtons: [W3WButtonData]
  
  
  init(viewModel: ViewModel, initialPanelHeight: CGFloat, ocrView: W3WOcrView, detents: W3WDetents) {
    self.viewModel = viewModel
    self.initialPanelHeight = initialPanelHeight
    self.ocrView = ocrView
    self.detents = detents
    
//    self.cameraMode = true
  }
  
  
  public var body: some View {
    ZStack {
      if viewModel.viewType == .uploaded {
        
        // still image and picker
        VStack {
          W3WOcrStillImageView(viewModel: viewModel)
            .padding(.top, W3WSettings.ocrTopPadding)
            .background(W3WCoreColor.darkBlue.suColor)
          
          W3WOcrBottomOverlay(viewModel: viewModel, initialPanelHeight: initialPanelHeight, detents: detents, cameraMode: cameraMode)
            .background(W3WCoreColor.darkBlue.suColor)
        }
        .background(W3WCoreColor.darkBlue.suColor)
        .edgesIgnoringSafeArea(.all)
        
      // live OCR view
      } else {
        //W3WSuOcrView(ocrView: ocrView)
        W3WSuOcrMockView(ocrView: ocrView)
          .edgesIgnoringSafeArea(.all)
          .background(Color.clear)

        W3WOcrBottomOverlay(viewModel: viewModel, initialPanelHeight: initialPanelHeight, detents: detents, cameraMode: cameraMode)
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
            Button {
              viewModel.closeButtonPressed()
            } label: {
              Image(systemName: "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.gray) // Adjust color as needed
                .padding()
            }
          }
        }
        Spacer() // Pushes the HStack (and button) to the top
      }
//      .padding(.top, UIApplication.shared.connectedScenes
//        .compactMap { $0 as? UIWindowScene }
//        .first?.windows.first?.safeAreaInsets.top ?? 0) // Consider safe area for top placement
      
      VStack {
        Spacer()
          .frame(height: 72.0)
        Text("Under Construction")
          .padding(6.0)
          .foregroundColor(viewModel.theme.value?.errorLabel?.suColor)
          .background(viewModel.theme.value?.errorElevated?.suColor)
          .font(viewModel.theme.value?.typefaces?.headline.suFont)
          .cornerRadius(16.0, corners: .allCorners)
        Spacer()
      }
    }
    .edgesIgnoringSafeArea(.bottom)
    .background(Color.clear)
  }
  
}





//public var body: some View {
//  ZStack {
//    if viewModel.viewType == .uploaded {
//      VStack {
//        W3WOcrStillImageView(viewModel: viewModel)
//          .padding(64.0)
//          .background(Color.gray)
//
//        // TODO: combine this with duplicate code above
//        VStack {
//          Spacer()
//            .frame(maxHeight: .infinity)
//          W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
//          W3WSuBottomSheet(scheme: viewModel.scheme, height: initialPanelHeight, detents: detents) {
//            W3WPanelScreen(viewModel: viewModel.panelViewModel)
//          }
//        }
//        .background(Color.gray)
//      }
//      .edgesIgnoringSafeArea(.all)
//    } else {
//      W3WSuOcrView(ocrView: ocrView)
//        .edgesIgnoringSafeArea(.all)
//
//      // TODO: move this down and remove duplicate code below
//      VStack {
//        Spacer()
//          .frame(maxHeight: .infinity)
//        W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
//        W3WSuBottomSheet(scheme: viewModel.scheme, height: initialPanelHeight, detents: detents) {
//          W3WPanelScreen(viewModel: viewModel.panelViewModel)
//        }
//      }
//    }
//  }
//  .edgesIgnoringSafeArea(.bottom)
//}

//}


//#Preview {
//  W3WOcrScreen(viewModel: W3WOcrViewModel(camera: W3WOcrCamera.get(camera: .back)!))
//}
