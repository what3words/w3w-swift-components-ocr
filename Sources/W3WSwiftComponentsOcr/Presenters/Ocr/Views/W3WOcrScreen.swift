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
        VStack {
            W3WOcrStillImageView(viewModel: viewModel)
              .padding(64.0)
              .background(Color.gray)

          // TODO: combine this with duplicate code above
          VStack {
            Spacer()
              .frame(maxHeight: .infinity)
            W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
            W3WSuBottomSheet(scheme: viewModel.theme.value?.basicScheme(), height: initialPanelHeight, detents: detents) {
              W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.bottomSheetScheme)
            }
          }
          .background(Color.gray)
        }
        .background(Color.gray)
        .edgesIgnoringSafeArea(.all)
      } else {
        W3WSuOcrView(ocrView: ocrView)
          .edgesIgnoringSafeArea(.all)
          .background(Color.clear)

        // TODO: move this down and remove duplicate code below
        VStack {
          Spacer()
            .frame(maxHeight: .infinity)
          W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
          W3WSuBottomSheet(scheme: viewModel.bottomSheetScheme, height: initialPanelHeight, detents: detents) {
            W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: viewModel.bottomSheetScheme)
          }
        }
      }
      
      // Add the Close Button here
      VStack {
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
        Spacer() // Pushes the HStack (and button) to the top
      }
//      .padding(.top, UIApplication.shared.connectedScenes
//        .compactMap { $0 as? UIWindowScene }
//        .first?.windows.first?.safeAreaInsets.top ?? 0) // Consider safe area for top placement
      
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
