//
//  MotionManager.swift
//  FloatLojic
//
//  Created by Graceila Natasya on 05/05/26.
//


//
//  MotionManager.swift
//  FloatLojic
//
//  Wraps CMMotionManager to provide a rolling 2-second buffer of MotionSamples.
//  Designed to be injected into a SwiftUI environment later via @StateObject.
//

import Foundation
import CoreMotion
import simd
import Combine

// MARK: - MotionManager

/// Manages Core Motion updates and maintains a fixed-duration rolling buffer.
/// All public APIs are `@MainActor` so SwiftUI views can safely observe
/// `isActive` and `samples` directly.
@MainActor
final class MotionManager: ObservableObject {

    // MARK: Configuration

    /// How often Core Motion delivers updates.
    /// 60 Hz gives ~120 samples in a 2-second window — plenty of resolution
    /// for a 1-second gesture window without flooding the CPU.
    private let updateInterval: TimeInterval = 1.0 / 60.0

    /// How many seconds of history to keep in the rolling buffer.
    /// 2 s covers a slow preparation + fast strike comfortably.
    private let bufferDuration: TimeInterval = 2.0

    // MARK: Published state

    /// Whether motion updates are currently running.
    @Published private(set) var isActive: Bool = false

    /// The rolling buffer of raw (smoothed) motion samples.
    /// Oldest sample is at index 0, newest at the last index.
    @Published private(set) var samples: [MotionSample] = []

    // MARK: Private

    private let manager = CMMotionManager()

    // Low-pass filter state — retains the previous smoothed acceleration
    // so each new reading can be blended toward it.
    // α close to 1.0 = heavy smoothing (lag); close to 0.0 = no smoothing.
    // 0.20 removes sensor noise while still tracking fast wrist snaps.
    private let lowPassAlpha: Double = 0.20
    private var smoothedAcceleration: SIMD3<Double> = .zero

    // Dedicated serial queue so the CMMotionManager callback never blocks
    // the main thread. Results are then dispatched to @MainActor.
    private let motionQueue = OperationQueue()

    // MARK: Init

    init() {
        motionQueue.maxConcurrentOperationCount = 1
        motionQueue.qualityOfService = .userInteractive
    }

    // MARK: Public API

    /// Starts device-motion updates if the hardware supports it.
    /// Safe to call multiple times — subsequent calls are no-ops.
    func startUpdates() {
        guard manager.isDeviceMotionAvailable, !isActive else { return }

        manager.deviceMotionUpdateInterval = updateInterval

        manager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical, // compensates for yaw drift
            to: motionQueue
        ) { [weak self] motionData, error in
            guard let self, let motionData, error == nil else { return }
            let sample = self.buildSample(from: motionData)
            Task { @MainActor in
                self.appendSample(sample)
            }
        }

        isActive = true
    }

    /// Stops device-motion updates and clears the buffer.
    func stopUpdates() {
        manager.stopDeviceMotionUpdates()
        isActive = false
        samples.removeAll()
        smoothedAcceleration = .zero
    }

    // MARK: Private helpers

    /// Converts a raw CMDeviceMotion frame into a MotionSample,
    /// applying an exponential low-pass filter to the acceleration.
    ///
    /// Low-pass formula:
    ///   smoothed = α * raw + (1 - α) * previousSmoothed
    ///
    /// This suppresses high-frequency vibration (table bumps, grip tremor)
    /// while preserving the intentional wrist arc of a hook gesture.
    private func buildSample(from motion: CMDeviceMotion) -> MotionSample {
        let rawAcc = SIMD3<Double>(
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z
        )
        let rawRot = SIMD3<Double>(
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z
        )

        // Exponential low-pass filter applied only to acceleration.
        // Rotation rate is inherently less noisy from the gyroscope,
        // so we pass it through raw to preserve fast angular events.
        let α = lowPassAlpha
        smoothedAcceleration = α * rawAcc + (1 - α) * smoothedAcceleration

        return MotionSample(
            timestamp: motion.timestamp,
            userAcceleration: smoothedAcceleration,
            rotationRate: rawRot
        )
    }

    /// Appends a new sample to the rolling buffer and prunes expired samples.
    private func appendSample(_ sample: MotionSample) {
        samples.append(sample)

        // Drop anything older than `bufferDuration` seconds relative to
        // the newest sample. Using the device timestamp (not wall clock)
        // prevents drift if the device sleeps mid-session.
        let cutoff = sample.timestamp - bufferDuration
        samples.removeAll { $0.timestamp < cutoff }

        // Safety cap — if timestamps misbehave, limit to 240 frames (4 s @ 60 Hz)
        if samples.count > 240 {
            samples.removeFirst(samples.count - 240)
        }
    }
}
