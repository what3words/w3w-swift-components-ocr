//
//  SwiftUIView.swift
//  w3w-swift-components-ocr
//
//  Created by Dave Duprey on 02/05/2025.
//


import SwiftUI
import W3WSwiftThemes

public struct W3WSuBottomSheet<Content: View>: View {
  
  public let scheme: W3WScheme?

  @State var height: CGFloat

  @State var detents = W3WDetents(detent: 64.0)

  @ViewBuilder let content: Content

  
  public var body: some View {
    VStack {
      Image(systemName: "minus")
        .padding(W3WPadding.light.value)
        .frame(maxWidth: .infinity)
        .background(W3WColor.background.current.suColor)
        .cornerRadius(scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value, corners: [.topLeft, .topRight])
      content
        .frame(height: height)
    }
    .background(scheme?.colors?.background?.current.suColor ?? W3WColor.background.current.suColor)
    .edgesIgnoringSafeArea(.bottom)
    .cornerRadius(scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value, corners: [.topLeft, .topRight])
    .gesture(
      DragGesture()
        .onChanged { value in
          let newHeight = self.height - (value.location.y - value.startLocation.y)
          if newHeight > 64.0 && newHeight < 700.0 {
            self.height = newHeight
          }
          if height < 0.0 {
            height = 0.0
          }
        }
        .onEnded { value in
          self.height = detents.nearest(value: height)
        }
    )
    }

}











//public struct W3WSuBottomSheet<Content: View>: View {
//  
//  public let scheme: W3WScheme?
//  @State public var height: CGFloat = 64.0
//  public let collapsedHeight: CGFloat
//  public let partialHeight: CGFloat
//  public let snapThreshold: CGFloat = 50
//  
//  @ViewBuilder let content: Content
//  
//  // MARK: - State Variables
//  @State private var dragOffset: CGFloat = .zero
//  @State private var sheetState: SheetState = .collapsed
//  @State private var currentHeight: CGFloat = 64.0 // Initialize with collapsed height
//  @State private var startDragHeight: CGFloat = 64.0 // Store the height when the drag starts
//  
//  public var body: some View {
//    GeometryReader { geometry in
//      VStack(spacing: 0) {
//        // Handle
//        RoundedRectangle(cornerRadius: scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value)
//          .fill(W3WColor.background.current.suColor)
//          .frame(width: 40, height: 6)
//          .padding(8)
//          .frame(maxWidth: .infinity)
//          .contentShape(Rectangle())
//        
//        // Content
//        content
//          .frame(maxHeight: .infinity)
//      }
//      .frame(width: geometry.size.width, height: currentHeight, alignment: .top)
//      .background(Color.orange)
//      .cornerRadius(scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value, corners: [.topLeft, .topRight])
//      .offset(y: geometry.size.height - currentHeight)
//      .gesture(
//        DragGesture()
//          .onChanged { value in
//            // Capture the starting height at the beginning of the drag
//            if value.translation.height == 0 {
//              startDragHeight = currentHeight
//            }
//            let newHeight = startDragHeight - value.translation.height
//            currentHeight = max(collapsedHeight, min(newHeight, height))
//          }
//          .onEnded { value in
//            withAnimation(.spring()) {
//              handleDragEnded(dragAmount: -value.translation.height)
//              // startDragHeight = currentHeight // Not strictly needed here as it will be updated on the next drag's start
//              dragOffset = .zero
//            }
//          }
//      )            .onAppear {
//        height = geometry.size.height * 0.8
//        currentHeight = collapsedHeight // Ensure initial height is correct
//        startDragHeight = collapsedHeight
//      }
//    }
//    .edgesIgnoringSafeArea(.bottom)
//  }
//  
//  // MARK: - Drag Handling Logic
//  private func handleDragEnded(dragAmount: CGFloat) {
//    // ... (same handleDragEnded logic as before) ...
//    switch sheetState {
//      case .collapsed:
//        if dragAmount < -snapThreshold {
//          sheetState = .partial
//        }
//      case .partial:
//        if dragAmount < -snapThreshold {
//          sheetState = .full
//        } else if dragAmount > snapThreshold {
//          sheetState = .collapsed
//        }
//      case .full:
//        if dragAmount > snapThreshold {
//          sheetState = .partial
//        }
//    }
//  }
//  
//  // MARK: - Sheet States
//  enum SheetState {
//    case collapsed
//    case partial
//    case full
//  }
//}


//import SwiftUI
//import W3WSwiftThemes
//
//public struct W3WSuBottomSheet<Content: View>: View {
//
//  let scheme: W3WScheme?
//
//  @ViewBuilder let content: Content
//
//  @State var startingOffset = 0.0
//  var endingOffset = 0.0
//  @State var currentHeight = 64.0
//  @State var endOffset = 0.0
//
//  public var body: some View {
//    VStack {
//      Text("Handle")
//        .frame(maxWidth: .infinity)
//        .background(W3WColor.background.current.suColor)
//        .cornerRadius(scheme?.styles?.cornerRadius?.value ?? W3WCornerRadius.regular.value, corners: [.topLeft, .topRight])
//      content
//        .frame(maxHeight: .infinity)
//    }
//    .background(Color.orange)
//      .frame(height: currentHeight)
//        .gesture(
//          DragGesture()
//            .onChanged{ value in
//              withAnimation(.spring()){
//                currentHeight = -value.location.y
//              }
//            }
//
//            .onEnded{ value in
//              withAnimation(.spring()){
//              }
//            }
//        )
//  }
//
//}
//
