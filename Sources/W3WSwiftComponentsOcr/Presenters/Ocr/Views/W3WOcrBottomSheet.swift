////
////  SwiftUIView.swift
////  w3w-swift-components-ocr
////
////  Created by Dave Duprey on 13/05/2025.
////
//
//import SwiftUI
//import Combine
//import W3WSwiftDesign
//import W3WSwiftPresenters
//
//
//struct W3WOcrBottomSheet<ViewModel: W3WOcrViewModelProtocol>: View {
//  
//  // main view model
//  @ObservedObject var viewModel: ViewModel
//  
//  let initialPanelHeight: CGFloat
//
//  var scheme: W3WScheme
//
//  var cameraMode: Binding<Bool>
//
//  @State var detents: W3WDetents
//
//  
//  var body: some View {
//    VStack {
//      Spacer()
//        .frame(maxHeight: .infinity)
//      W3WOcrMainButtons(viewModel: viewModel, cameraMode: cameraMode)
//      W3WSuBottomSheet(scheme: viewModel.bottomSheetScheme, height: initialPanelHeight, detents: detents, content: {
//        W3WPanelScreen(viewModel: viewModel.panelViewModel, scheme: scheme)
//      })
//    }
//  }
//}
//
//
//
////#Preview {
////  W3WOcrBottomSheet()
////}
