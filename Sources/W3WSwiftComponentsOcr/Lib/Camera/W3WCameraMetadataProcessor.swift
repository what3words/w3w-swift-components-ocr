//
//  W3WCameraMetadataProcessor.swift
//  w3w-swift-components-ocr
//
//  Created by Au Nguyen on 11/07/2026.
//
#if !os(tvOS) && !os(watchOS)

import Foundation
import AVKit

/// handles AVCaptureMetadataOutput callbacks for machine readable codes (QR)
/// AVCaptureMetadataOutputObjectsDelegate needs an NSObject derivative, same
/// pattern as W3WCameraImageProcessor
@available(macCatalyst 14.0, *)
class W3WCameraMetadataProcessor: NSObject, AVCaptureMetadataOutputObjectsDelegate {

  // MARK: Vars

  /// callback for any detected QR code payload
  var onQRCode: (String) -> () = { _ in }

  /// gate consulted before anything else; while false, sightings are dropped
  /// without sliding the suppression window (so re-activating delivers immediately)
  var isActive: () -> Bool = { true }

  /// minimum quiet period before the same payload is delivered again; a code
  /// sitting in frame is reported by AVFoundation continuously - it should fire once
  let repeatSuppressionInterval: TimeInterval = 1.5

  /// the last payload seen, and when
  private var lastPayload: String?
  private var lastSeenAt: Date?

  /// last time a suppressed sighting was logged (noise control — sightings arrive
  /// continuously while a code is in frame)
  private var lastDropLogAt: Date?


  // MARK: AVCaptureMetadataOutputObjectsDelegate


  /// called when metadata (QR) is detected in the camera feed
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          let payload = object.stringValue else {
      return
    }

    emitIfNeeded(payload: payload, at: Date())
  }


  /// gate + duplicate suppression + delivery (internal for testing)
  func emitIfNeeded(payload: String, at now: Date) {
    guard isActive() else {
      logDrop("inactive (not in live scan mode)", payload: payload, at: now)
      return
    }

    if shouldEmit(payload: payload, at: now) {
      print("W3WOcr QR: sighting EMITTED: \(payload)")
      onQRCode(payload)
    } else {
      logDrop("duplicate within \(repeatSuppressionInterval)s window", payload: payload, at: now)
    }
  }


  /// log suppressed sightings at most once per second
  private func logDrop(_ reason: String, payload: String, at now: Date) {
    if let lastDropLogAt, now.timeIntervalSince(lastDropLogAt) < 1 { return }
    lastDropLogAt = now
    print("W3WOcr QR: sighting dropped — \(reason): \(payload)")
  }


  /// sliding window duplicate suppression: repeated sightings of the same payload
  /// keep pushing the window forward, so a code held in frame emits exactly once
  /// and can only re-emit after it has been out of sight for the quiet period
  func shouldEmit(payload: String, at now: Date) -> Bool {
    defer {
      lastPayload = payload
      lastSeenAt = now
    }

    if payload == lastPayload,
       let lastSeenAt,
       now.timeIntervalSince(lastSeenAt) < repeatSuppressionInterval {
      return false
    }

    return true
  }

}

#endif
