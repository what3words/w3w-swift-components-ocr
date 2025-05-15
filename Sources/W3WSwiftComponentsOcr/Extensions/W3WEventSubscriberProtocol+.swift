////
////  W3WEventSubscriberProtocol+.swift
////  TestApp
////
////  Created by Dave Duprey on 16/02/2025.
////
//
//import Foundation
//import Combine
//import W3WSwiftCore
//
//// MAYBE ADD THIS TO W3WSwiftCore
//
//@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
//public extension W3WEventSubscriberProtocol {
//  
//  @discardableResult func subscribe<T>(to: Published<T>.Publisher?, handler: @escaping (T) -> ()) -> AnyCancellable? {
//    let subscription = to?.sink(
//      receiveCompletion: { _ in },
//      receiveValue: { event in  handler(event) })
//    
//    if let s = subscription {
//      subscriptions.insert(s)
//    }
//    
//    return subscription
//  }
//  
//  
//  @discardableResult func subscribe<T>(to: Published<T>.Publisher?, debounce: W3WDuration, handler: @escaping (T) -> ()) -> AnyCancellable? {
//    let subscription = to?.debounce(for: RunLoop.SchedulerTimeType.Stride(debounce.seconds), scheduler: RunLoop.main).sink(
//      receiveCompletion: { _ in },
//      receiveValue: { event in  handler(event) })
//    
//    if let s = subscription {
//      subscriptions.insert(s)
//    }
//    
//    return subscription
//  }
//  
//}
